import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/providers/pedido_recebido_provider/pedido_recebido_provider.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';
import 'package:quiosque_app/src/shared/widget/mini_mapa.dart';
import 'package:quiosque_app/src/shared/widget/modais.dart';
import 'package:quiosque_app/src/shared/widget/pedido_cards.dart';

class PedidoDescricaoPage extends ConsumerStatefulWidget {
  final PedidoRecebido pedido;
  const PedidoDescricaoPage({super.key, required this.pedido});

  @override
  ConsumerState<PedidoDescricaoPage> createState() =>
      _PedidoDescricaoPageState();
}

class _PedidoDescricaoPageState extends ConsumerState<PedidoDescricaoPage> {
  final List<TextEditingController> _codigo =
      List.generate(4, (_) => TextEditingController());
  bool _invalido = false;
  // Cópia local do pedido: começa no status recebido e é atualizada em tela
  // (sem voltar para a lista) quando o pedido avança — ex.: "Entregar".
  late PedidoRecebido _pedido = widget.pedido;

  @override
  void dispose() {
    for (final c in _codigo) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pedido = _pedido;
    // Pedido ainda não aceito: usa os botões "Aceitar" / "Recusar".
    final naoAceito = pedido.status == 'aceitar';
    // Pedido de cliente já aceito: precisa "iniciar preparo" antes de seguir
    // para entrega. (Internos já nascem em preparo.)
    final clienteAceito = !pedido.interno && pedido.status == 'aceito';
    // Pedido de cliente já em entrega: aí sim pede o código de verificação.
    final emEntrega = pedido.status == 'entregando';
    // Pedido de cliente ainda em preparo: precisa "sair para entrega" antes de
    // poder validar o código e finalizar. (Internos finalizam direto.)
    final clientePreparando = !pedido.interno && pedido.status == 'preparando';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voltar"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PedidoClienteCard(pedido: pedido),
              const SizedBox(height: 16),
              PedidoItensCard(pedido: pedido),
              const SizedBox(height: 28),
              // Localização e código de verificação só existem para pedidos do
              // cliente; pedidos feitos pelo quiosque (balcão) não os possuem.
              if (!pedido.interno) ...[
                if (pedido.temLocalizacao)
                  MiniMapa(
                    clienteLat: pedido.clienteLat!,
                    clienteLng: pedido.clienteLng!,
                  ),
                const SizedBox(height: 16),
                // O código de verificação só é exigido quando o pedido já saiu
                // para entrega (EM_ENTREGA).
                if (emEntrega) ...[
                  Text('Código de verificação:',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.outline)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => _caixaCodigo(i, theme)),
                  ),
                  const SizedBox(height: 28),
                ],
              ],
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _invalido ? Colors.grey : const Color(0xFF1D3557),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: naoAceito
                      ? _aceitar
                      : clienteAceito
                          ? _iniciarPreparo
                          : (clientePreparando
                              ? _sairParaEntrega
                              : _finalizar),
                  child: Text(
                      naoAceito
                          ? 'ACEITAR'
                          : clienteAceito
                              ? 'INICIAR PREPARO'
                              : clientePreparando
                                  ? 'ENTREGAR'
                                  : (_invalido
                                      ? 'CÓDIGO INVÁLIDO'
                                      : 'FINALIZAR'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: naoAceito
                      ? _recusar
                      : () => context.push('/cancelarPedido', extra: pedido),
                  child: Text(naoAceito ? 'RECUSAR' : 'CANCELAR',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _caixaCodigo(int index, ThemeData theme) {
    return Container(
      width: 44,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        controller: _codigo[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          UpperCaseTextFormatter(),
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (v) {
          if (_invalido) setState(() => _invalido = false);
          if (v.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: theme.colorScheme.outline, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 3),
          ),
        ),
      ),
    );
  }

  // Aceita um pedido ainda não aceito (passa a "preparando").
  Future<void> _aceitar() async {
    try {
      await ref.read(pedidoRecebidoProvider.notifier).aceitar(widget.pedido.id);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    }
  }

  // Recusa um pedido ainda não aceito.
  Future<void> _recusar() async {
    try {
      await ref.read(pedidoRecebidoProvider.notifier).rejeitar(widget.pedido.id);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    }
  }

  // Move um pedido de cliente de "aceito" para "preparando", iniciando o
  // preparo. Permanece na tela de descrição: apenas o status (card) e o botão
  // mudam.
  Future<void> _iniciarPreparo() async {
    try {
      await ref
          .read(pedidoRecebidoProvider.notifier)
          .definirStatus(_pedido.id, 'preparando');
      if (mounted) {
        setState(() => _pedido = _pedido.copyWith(status: 'preparando'));
      }
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    }
  }

  // Move um pedido de cliente de "preparando" para "entregando" (EM_ENTREGA),
  // habilitando a etapa de validação do código. Permanece na tela de descrição:
  // apenas o status (card) e o botão mudam. A lista já é invalidada pelo
  // provider, então reflete o novo status quando o usuário voltar.
  Future<void> _sairParaEntrega() async {
    try {
      await ref
          .read(pedidoRecebidoProvider.notifier)
          .definirStatus(_pedido.id, 'entregando');
      if (mounted) {
        setState(() => _pedido = _pedido.copyWith(status: 'entregando'));
      }
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    }
  }

  Future<void> _finalizar() async {
    // Pedido feito pelo quiosque não exige código de verificação.
    if (widget.pedido.interno) {
      try {
        await ref
            .read(pedidoRecebidoProvider.notifier)
            .finalizar(widget.pedido.id);
        if (mounted) context.pop();
      } on ApiException catch (e) {
        if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
      }
      return;
    }
    final codigo = _codigo.map((c) => c.text.trim()).join();
    if (codigo.length < 4) {
      await mostrarAlerta(context,
          mensagem: 'Código do cliente não inserido!');
      return;
    }
    // A validação do código é feita pelo back-end, que finaliza o pedido.
    try {
      final valido = await ref
          .read(pedidoRecebidoProvider.notifier)
          .validarCodigo(widget.pedido.id, codigo);
      if (!valido) {
        if (mounted) setState(() => _invalido = true);
        if (mounted) {
          await mostrarAlerta(context,
              mensagem: 'Código inválido ou inexistente!');
        }
        return;
      }
      if (mounted) context.pop();
    } on ApiException catch (e) {
      // Sem isto, qualquer erro do back-end (ex.: 404/403) falhava em silêncio:
      // o botão não dava retorno nenhum.
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
