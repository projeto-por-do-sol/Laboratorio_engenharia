import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/providers/pagina_quiosque_provider/pagina_quiosque_provider.dart';
import 'package:quiosque_app/src/shared/models/adicionaisItem.dart';
import 'package:quiosque_app/src/shared/models/cardapio_item.dart';
import 'package:quiosque_app/src/shared/utils/formatters.dart';
import 'package:quiosque_app/src/shared/utils/image_picker_util.dart';
import 'package:quiosque_app/src/shared/utils/imagem_remota.dart';
import 'package:quiosque_app/src/shared/widget/modais.dart';

class ItemFormPage extends ConsumerStatefulWidget {
  final String secaoId;
  final CardapioItem? item;

  const ItemFormPage({super.key, required this.secaoId, this.item});

  bool get editando => item != null;

  @override
  ConsumerState<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends ConsumerState<ItemFormPage> {
  late String _nome;
  late String? _imgPath;
  late List<String> _ingredientes;
  late List<AdicionaisItem> _complementos;
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nome = item?.nome ?? '';
    _imgPath = item?.imgPath;
    _ingredientes = List<String>.from(item?.ingredientes ?? const []);
    _complementos = List<AdicionaisItem>.from(item?.complementos ?? const []);
    _descricaoController.text = item?.descricao ?? '';
    if (item != null && item.preco > 0) {
      _valorController.text = formatarCentavosSemSimbolo(item.preco);
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _imagem(theme),
                        _nomeHeader(theme),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _descricao(theme),
                              const SizedBox(height: 16),
                              _valor(theme),
                              const SizedBox(height: 16),
                              _listaSimples(
                                theme,
                                titulo: 'Ingredientes:',
                                itens: _ingredientes,
                                onAdicionar: _adicionarIngrediente,
                                onRemover: _removerIngrediente,
                              ),
                              const SizedBox(height: 16),
                              _listaComplementos(theme),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _rodape(theme),
              ],
            ),
          ),
          if (_processando)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- Seções do formulário ----------------

  Widget _imagem(ThemeData theme) {
    // Preview quadrado (1:1), igual ao formato em que o item aparece no cardápio.
    return GestureDetector(
      onTap: _trocarImagem,
      child: Container(
        width: double.infinity,
        color: Colors.grey[350],
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 160,
              height: 160,
              child: provedorImagem(_imgPath) != null
                  ? Image(image: provedorImagem(_imgPath)!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[400],
                      child: const Center(
                          child: Icon(Icons.file_upload_outlined, size: 28)),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nomeHeader(ThemeData theme) {
    return InkWell(
      onTap: _editarNome,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _nome.isEmpty ? 'Nome do item' : _nome,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _nome.isEmpty
                      ? theme.colorScheme.outline.withValues(alpha: 0.6)
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit, size: 18),
              onPressed: _editarNome,
            ),
          ],
        ),
      ),
    );
  }

  Widget _descricao(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descrição:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: _descricaoController,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.outline, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _valor(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Valor:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: _valorController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [MoneyInputFormatter()],
          decoration: InputDecoration(
            prefixText: 'R\$ ',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: theme.colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.outline, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _listaSimples(
    ThemeData theme, {
    required String titulo,
    required List<String> itens,
    required VoidCallback onAdicionar,
    required void Function(int index) onRemover,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ...itens.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13))),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => onRemover(e.key),
                  ),
                ],
              ),
            )),
        _botaoAdicionar(theme, onAdicionar),
      ],
    );
  }

  Widget _listaComplementos(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Complementos:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ..._complementos.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Text(e.value.nomeAdicional,
                          style: const TextStyle(fontSize: 13))),
                  Text(formatarPreco(e.value.precoAdicional),
                      style: TextStyle(
                          fontSize: 13, color: theme.colorScheme.primary)),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _removerComplemento(e.key),
                  ),
                ],
              ),
            )),
        _botaoAdicionar(theme, _adicionarComplemento),
      ],
    );
  }

  Widget _botaoAdicionar(ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline,
                size: 18, color: theme.colorScheme.outline),
            const SizedBox(width: 6),
            Text('Adicionar',
                style: TextStyle(
                    fontSize: 13, color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _rodape(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.editando) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _apagarItem,
                child: const Text('APAGAR ITEM',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.outline,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => context.pop(),
                  child: const Text('CANCELAR',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _salvar,
                  child: Text(widget.editando ? 'SALVAR' : 'ADICIONAR',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  // ---------------- Ações ----------------

  Future<void> _trocarImagem() async {
    final path = await escolherImagem(context, aspectRatio: aspectRatioItem);
    if (path != null) setState(() => _imgPath = path);
  }

  Future<void> _editarNome() async {
    final novo = await mostrarModalCampo(context,
        label: 'Nome do item:', textoConfirmar: 'Salvar', valorInicial: _nome);
    if (novo != null) setState(() => _nome = novo);
  }

  Future<void> _adicionarIngrediente() async {
    final ing = await mostrarModalCampo(context,
        label: 'Ingrediente:', textoConfirmar: 'Adicionar');
    if (ing != null) setState(() => _ingredientes.add(ing));
  }

  Future<void> _removerIngrediente(int index) async {
    final ok = await mostrarModalConfirmacaoDestaque(context,
        pergunta: 'Remover ingrediente?');
    if (ok == true) setState(() => _ingredientes.removeAt(index));
  }

  Future<void> _adicionarComplemento() async {
    final res = await mostrarModalComplemento(context);
    if (res != null) {
      setState(() => _complementos.add(AdicionaisItem(
            nomeAdicional: res.$1,
            precoAdicional: parsePrecoParaCentavos(res.$2),
          )));
    }
  }

  Future<void> _removerComplemento(int index) async {
    final ok = await mostrarModalConfirmacaoDestaque(context,
        pergunta: 'Remover complemento?');
    if (ok == true) setState(() => _complementos.removeAt(index));
  }

  Future<void> _apagarItem() async {
    final ok = await mostrarModalConfirmacaoDestaque(context,
        pergunta: 'Apagar item?');
    if (ok != true) return;

    setState(() => _processando = true);
    try {
      await ref
          .read(paginaQuiosqueProvider.notifier)
          .removerItem(widget.secaoId, widget.item!.id);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _salvar() async {
    if (_nome.trim().isEmpty) {
      await mostrarAlerta(context, mensagem: 'Adicione um nome ao item!');
      return;
    }
    if (_imgPath == null) {
      await mostrarAlerta(context, mensagem: 'Adicione uma imagem ao item!');
      return;
    }
    if (_ingredientes.isEmpty) {
      await mostrarAlerta(context, mensagem: 'Adicione um ingrediente ao item!');
      return;
    }

    setState(() => _processando = true);
    try {
      await ref.read(paginaQuiosqueProvider.notifier).salvarItem(
            secaoId: widget.secaoId,
            itemId: widget.item?.id,
            nome: _nome.trim(),
            descricao: _descricaoController.text.trim(),
            precoCentavos: parsePrecoParaCentavos(_valorController.text),
            ingredientes: _ingredientes,
            complementos: _complementos,
            imagemPath: _imgPath,
          );
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
      return;
    } finally {
      if (mounted) setState(() => _processando = false);
    }

    if (!mounted) return;
    if (widget.editando) {
      context.pop();
    } else {
      await mostrarAlerta(context,
          mensagem: 'Item adicionado com sucesso',
          icone: Icons.check_circle_outline);
      if (mounted) context.pop();
    }
  }
}
