import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/providers/carrinho_interno_provider/carrinho_interno_provider.dart';
import 'package:quiosque_app/src/shared/models/adicionaisItem.dart';
import 'package:quiosque_app/src/shared/models/cardapio_item.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';
import 'package:quiosque_app/src/shared/utils/formatters.dart';
import 'package:quiosque_app/src/shared/utils/imagem_remota.dart';

class ItemSelecaoPage extends ConsumerStatefulWidget {
  final CardapioItem item;
  // Quando true, a tela serve apenas para visualizar o item (sem seleção de
  // ingredientes/complementos, quantidade ou botão de adicionar ao carrinho).
  final bool somenteVisualizacao;
  const ItemSelecaoPage(
      {super.key, required this.item, this.somenteVisualizacao = false});

  @override
  ConsumerState<ItemSelecaoPage> createState() => _ItemSelecaoPageState();
}

class _ItemSelecaoPageState extends ConsumerState<ItemSelecaoPage> {
  final Set<String> _ingredientesRemovidos = {};
  final Set<int> _complementosSelecionados = {};
  int _qtde = 1;

  // Preço de uma unidade (item + complementos selecionados).
  int get _precoUnitario {
    var total = widget.item.preco;
    for (final i in _complementosSelecionados) {
      total += widget.item.complementos[i].precoAdicional;
    }
    return total;
  }

  // Preço total considerando a quantidade.
  int get _precoTotal => _precoUnitario * _qtde;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voltar'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Imagem do item: 300px de altura, ocupando toda a largura.
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: provedorImagem(item.imgPath) != null
                          ? Image(
                              image: provedorImagem(item.imgPath)!,
                              fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[350],
                              child: Icon(Icons.fastfood,
                                  size: 48, color: theme.colorScheme.outline),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Nome, descrição e a caixa de preço.
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.nome,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.outline,
                                        )),
                                    if (item.descricao.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(item.descricao,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                theme.colorScheme.outlineVariant,
                                          )),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              _caixaPreco(theme),
                            ],
                          ),
                          if (item.ingredientes.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            _divisor(theme),
                            const SizedBox(height: 15),
                            _cabecalhoSecao(
                              theme,
                              titulo: 'Ingredientes',
                              badge: widget.somenteVisualizacao
                                  ? ''
                                  : 'Toque para remover',
                              corBadge: theme.colorScheme.tertiary,
                            ),
                            ...item.ingredientes
                                .map((ing) => _ingredienteTile(theme, ing)),
                          ],
                          if (item.complementos.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            _divisor(theme),
                            const SizedBox(height: 15),
                            _cabecalhoSecao(
                              theme,
                              titulo: 'Complementos',
                              badge: widget.somenteVisualizacao
                                  ? ''
                                  : 'Opcional',
                              corBadge: theme.colorScheme.tertiary,
                            ),
                            ...item.complementos
                                .asMap()
                                .entries
                                .map((e) => _complementoTile(theme, e.key, e.value)),
                          ],
                          const SizedBox(height: 15),
                          if (!widget.somenteVisualizacao) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Quantidade:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.outline,
                                      )),
                                ),
                                _alterarQuantidade(theme),
                              ],
                            ),
                            const SizedBox(height: 15),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!widget.somenteVisualizacao)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _botaoAdicionar(theme),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- Componentes ----------------

  // Caixa "A partir de R$ X" ao lado do nome do item.
  Widget _caixaPreco(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.primary, width: 1),
      ),
      child: Column(
        children: [
          Text('A partir de',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.tertiary,
              )),
          Text(formatarPreco(widget.item.preco),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              )),
        ],
      ),
    );
  }

  Widget _divisor(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.15),
    );
  }

  Widget _cabecalhoSecao(
    ThemeData theme, {
    required String titulo,
    required String badge,
    required Color corBadge,
  }) {
    return Row(
      children: [
        Text(titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            )),
        const Spacer(),
        if (badge.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: corBadge, width: 1),
          ),
          child: Text(badge,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: corBadge,
              )),
        ),
      ],
    );
  }

  static String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  // Checkbox de remoção de ingrediente (texto riscado + "Removido" quando ativo).
  Widget _ingredienteTile(ThemeData theme, String ing) {
    final marcado = _ingredientesRemovidos.contains(ing);
    return GestureDetector(
      onTap: widget.somenteVisualizacao
          ? null
          : () => setState(() {
                if (marcado) {
                  _ingredientesRemovidos.remove(ing);
                } else {
                  _ingredientesRemovidos.add(ing);
                }
              }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: marcado ? theme.colorScheme.secondary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: marcado
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary,
          ),
        ),
        child: Row(
          children: [
            _caixaCheck(
              theme,
              marcado: marcado,
              corMarcada: theme.colorScheme.primary,
              corCheck: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _capitalizar(ing),
                style: TextStyle(
                  fontSize: 16,
                  color: marcado
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  decoration: marcado
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: theme.colorScheme.outline,
                  decorationThickness: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (marcado)
              Text('Removido',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  )),
          ],
        ),
      ),
    );
  }

  // Checkbox de adição de complemento (destaque amarelo + preço quando ativo).
  Widget _complementoTile(
      ThemeData theme, int index, AdicionaisItem complemento) {
    const amareloTexto = Color(0xff8B6540);
    const amareloDetalhes = Color(0xFFFDD06A);
    const amareloFundo = Color(0xFFFFF3DC);
    final marcado = _complementosSelecionados.contains(index);

    return GestureDetector(
      onTap: widget.somenteVisualizacao
          ? null
          : () => setState(() {
                if (marcado) {
                  _complementosSelecionados.remove(index);
                } else {
                  _complementosSelecionados.add(index);
                }
              }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: marcado ? amareloFundo : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: marcado ? amareloDetalhes : theme.colorScheme.secondary,
          ),
        ),
        child: Row(
          children: [
            _caixaCheck(
              theme,
              marcado: marcado,
              corMarcada: amareloDetalhes,
              corCheck: theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _capitalizar(complemento.nomeAdicional),
                style: TextStyle(
                  fontSize: 16,
                  color: marcado ? amareloTexto : theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '+ ${formatarPreco(complemento.precoAdicional)}',
              style: TextStyle(
                fontSize: 14,
                color: marcado ? amareloTexto : theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quadradinho do checkbox usado pelos tiles de ingrediente/complemento.
  Widget _caixaCheck(
    ThemeData theme, {
    required bool marcado,
    required Color corMarcada,
    required Color corCheck,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: marcado ? corMarcada : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: marcado ? corMarcada : theme.colorScheme.secondary,
          width: 2,
        ),
      ),
      child: marcado ? Icon(Icons.check, size: 16, color: corCheck) : null,
    );
  }

  // Seletor de quantidade com botões - / +.
  Widget _alterarQuantidade(ThemeData theme) {
    Widget icone(IconData icone, {required bool remover}) {
      final estaAtivo =
          !(remover && _qtde == 1) && !(!remover && _qtde == 99);
      return IconButton.filled(
        icon: Icon(icone),
        style: IconButton.styleFrom(
          backgroundColor: remover
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
          foregroundColor: remover
              ? theme.colorScheme.primary
              : theme.colorScheme.onTertiary,
          disabledBackgroundColor: const Color(0xFFF5F5F5),
          disabledForegroundColor: const Color(0xFFD0D0D0),
        ),
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
        iconSize: 30,
        onPressed: estaAtivo
            ? () => setState(() => _qtde += remover ? -1 : 1)
            : null,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary, width: 1),
      ),
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            icone(Icons.remove, remover: true),
            const Spacer(),
            Text(_qtde.toString(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
            const Spacer(),
            icone(Icons.add, remover: false),
          ],
        ),
      ),
    );
  }

  // Botão "Adicionar ao carrinho" com o preço total à direita.
  Widget _botaoAdicionar(ThemeData theme) {
    return ElevatedButton(
      onPressed: _adicionar,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onTertiary,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Adicionar ao carrinho',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(formatarPreco(_precoTotal),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _adicionar() {
    final complementosNomes = _complementosSelecionados
        .map((i) => widget.item.complementos[i].nomeAdicional)
        .toList();
    // Ids para enviar o pedido à API (item, acompanhamentos e ingredientes
    // removidos). Acompanhamentos sem id e ingredientes sem id são ignorados.
    final acompanhamentosId = _complementosSelecionados
        .map((i) => widget.item.complementos[i].id)
        .whereType<int>()
        .toList();
    final ingredientesId = _ingredientesRemovidos
        .map((nome) => widget.item.ingredientesIds[nome])
        .whereType<int>()
        .toList();
    ref.read(carrinhoInternoProvider.notifier).adicionar(
          ItemPedidoRecebido(
            nome: widget.item.nome,
            qtde: _qtde,
            valorUnitario: _precoUnitario,
            ingredientesRemovidos: _ingredientesRemovidos.toList(),
            complementos: complementosNomes,
            itemId: int.tryParse(widget.item.id),
            acompanhamentosId: acompanhamentosId,
            ingredientesId: ingredientesId,
          ),
        );
    context.pop();
  }
}
