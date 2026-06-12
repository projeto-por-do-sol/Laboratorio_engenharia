import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiosque_app/src/shared/utils/formatters.dart';
import 'package:quiosque_app/src/shared/utils/verificarHorario.dart';

/// Formata a entrada como horário HH:MM (24h) à medida que o usuário digita.
class _HorarioInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > 4) digitos = digitos.substring(0, 4);
    String texto = digitos;
    if (digitos.length >= 3) {
      texto = '${digitos.substring(0, 2)}:${digitos.substring(2)}';
    }
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

InputDecoration _campoDecoration(BuildContext context) {
  return InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:
          BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:
          BorderSide(color: Theme.of(context).colorScheme.primary, width: 3),
    ),
  );
}

Widget _botoesModal(
  BuildContext context, {
  required String textoConfirmar,
  required VoidCallback onConfirmar,
}) {
  final scheme = Theme.of(context).colorScheme;
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.secondary,
            foregroundColor: scheme.outline,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onTertiary,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onConfirmar,
          child: Text(textoConfirmar.toUpperCase(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    ],
  );
}

Future<T?> _abrirSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: child,
      ),
    ),
  );
}

/// Modal com um único campo de texto e botões CANCELAR / [textoConfirmar].
/// Retorna o texto digitado ou null se cancelado.
Future<String?> mostrarModalCampo(
  BuildContext context, {
  required String label,
  required String textoConfirmar,
  String valorInicial = '',
  bool numerico = false,
}) {
  final controller = TextEditingController(text: valorInicial);
  return _abrirSheet<String>(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.outline)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          autofocus: true,
          keyboardType: numerico ? TextInputType.number : TextInputType.text,
          inputFormatters:
              numerico ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: _campoDecoration(context),
        ),
        const SizedBox(height: 12),
        _botoesModal(
          context,
          textoConfirmar: textoConfirmar,
          onConfirmar: () {
            final texto = controller.text.trim();
            if (texto.isEmpty) return;
            Navigator.pop(context, texto);
          },
        ),
      ],
    ),
  );
}

/// Modal de horário com campos Início e Fim. Retorna (abre, fecha) ou null.
Future<(String, String)?> mostrarModalHorario(
  BuildContext context, {
  String abreInicial = '',
  String fechaInicial = '',
}) {
  final inicioController = TextEditingController(text: abreInicial);
  final fimController = TextEditingController(text: fechaInicial);

  Widget campo(String titulo, TextEditingController c) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(titulo,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 4),
          TextField(
            controller: c,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [_HorarioInputFormatter()],
            decoration: _campoDecoration(context).copyWith(hintText: 'HH:MM'),
          ),
        ],
      ),
    );
  }

  String? erro;
  return _abrirSheet<(String, String)>(
    context,
    StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Horário de atendimento',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 12),
            Row(
              children: [
                campo('Início', inicioController),
                const SizedBox(width: 16),
                campo('Fim', fimController),
              ],
            ),
            if (erro != null) ...[
              const SizedBox(height: 8),
              Text(erro!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 12),
            _botoesModal(
              context,
              textoConfirmar: 'Salvar',
              onConfirmar: () {
                final abre = inicioController.text.trim();
                final fecha = fimController.text.trim();
                if (abre.isEmpty || fecha.isEmpty) {
                  setState(() => erro = 'Preencha os dois horários.');
                  return;
                }
                if (!horarioValido(abre) || !horarioValido(fecha)) {
                  setState(() =>
                      erro = 'Informe um horário válido no formato HH:MM (24h).');
                  return;
                }
                if (abre == fecha) {
                  setState(() =>
                      erro = 'O horário de abertura e fechamento não podem ser iguais.');
                  return;
                }
                Navigator.pop(context, (abre, fecha));
              },
            ),
          ],
        );
      },
    ),
  );
}

/// Modal para selecionar os dias da semana em que o quiosque fica aberto.
/// Recebe e retorna uma lista de 7 booleanos (índice 0 = Domingo ... 6 = Sábado).
/// Retorna null se cancelado.
Future<List<bool>?> mostrarModalDias(
  BuildContext context, {
  required List<bool> diasIniciais,
}) {
  const nomes = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  final selecionados = List<bool>.from(diasIniciais);
  final cor = Theme.of(context).colorScheme.outline;
  final primaria = Theme.of(context).colorScheme.primary;

  return _abrirSheet<List<bool>>(
    context,
    StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dias de funcionamento',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: cor)),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final ativo = selecionados[i];
                return ChoiceChip(
                  label: Text(nomes[i]),
                  selected: ativo,
                  onSelected: (_) =>
                      setState(() => selecionados[i] = !selecionados[i]),
                  selectedColor: primaria,
                  labelStyle: TextStyle(
                      color: ativo ? Colors.white : cor,
                      fontWeight: FontWeight.w600),
                );
              }),
            ),
            const SizedBox(height: 16),
            _botoesModal(
              context,
              textoConfirmar: 'Salvar',
              onConfirmar: () => Navigator.pop(context, selecionados),
            ),
          ],
        );
      },
    ),
  );
}

/// Modal de complemento com campos Complemento e Valor (em reais).
/// Retorna (nome, valorEmCentavos) ou null.
Future<(String, String)?> mostrarModalComplemento(
  BuildContext context, {
  String nomeInicial = '',
  String valorInicial = '',
}) {
  final nomeController = TextEditingController(text: nomeInicial);
  final valorController = TextEditingController(text: valorInicial);
  final cor = Theme.of(context).colorScheme.outline;

  Widget campo(String label, TextEditingController c, {bool numerico = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor)),
        const SizedBox(height: 4),
        TextField(
          controller: c,
          keyboardType:
              numerico ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: numerico ? [MoneyInputFormatter()] : null,
          decoration: numerico
              ? _campoDecoration(context).copyWith(prefixText: 'R\$ ')
              : _campoDecoration(context),
        ),
      ],
    );
  }

  return _abrirSheet<(String, String)>(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        campo('Complemento:', nomeController),
        const SizedBox(height: 10),
        campo('Valor:', valorController, numerico: true),
        const SizedBox(height: 12),
        _botoesModal(
          context,
          textoConfirmar: 'Adicionar',
          onConfirmar: () {
            final nome = nomeController.text.trim();
            if (nome.isEmpty) return;
            Navigator.pop(context, (nome, valorController.text.trim()));
          },
        ),
      ],
    ),
  );
}

/// Modal de confirmação genérico (pergunta + NÃO / SIM). Retorna true se SIM.
Future<bool?> mostrarModalConfirmacao(
  BuildContext context, {
  required String pergunta,
  IconData icone = Icons.delete_outline,
  String textoNegar = 'NÃO',
  String textoConfirmar = 'SIM',
}) {
  final cor = Theme.of(context).colorScheme.outline;
  return _abrirSheet<bool>(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: cor, size: 22),
            const SizedBox(width: 12),
            Flexible(
              child: Text(pergunta.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: cor)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(textoNegar.toUpperCase(),
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: cor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(textoConfirmar.toUpperCase(),
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: cor)),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Modal de confirmação no estilo do logout (ícone à esquerda + pergunta
/// centralizada + botões NÃO / SIM destacados). Retorna true se SIM.
Future<bool?> mostrarModalConfirmacaoDestaque(
  BuildContext context, {
  required String pergunta,
  IconData icone = Icons.delete_forever_outlined,
}) {
  return showModalBottomSheet<bool>(
    backgroundColor: Theme.of(context).colorScheme.surface,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 15,
                    child: Icon(
                      icone,
                      size: 26,
                      color: Theme.of(ctx).colorScheme.outline,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      pergunta.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.primary,
                        foregroundColor: Theme.of(ctx).colorScheme.onTertiary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      label: const Text('NÃO',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.secondary,
                        foregroundColor: Theme.of(ctx).colorScheme.outline,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      label: const Text('SIM',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Modal de alerta simples (ícone + mensagem + OK).
Future<void> mostrarAlerta(
  BuildContext context, {
  required String mensagem,
  IconData icone = Icons.info_outline,
}) {
  final cor = Theme.of(context).colorScheme.outline;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(mensagem,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: cor)),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: cor)),
          ),
        ),
      ],
    ),
  );
}
