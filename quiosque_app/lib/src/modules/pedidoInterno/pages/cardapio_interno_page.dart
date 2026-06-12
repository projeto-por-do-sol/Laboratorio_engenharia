import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/providers/carrinho_interno_provider/carrinho_interno_provider.dart';
import 'package:quiosque_app/providers/pagina_quiosque_provider/pagina_quiosque_provider.dart';
import 'package:quiosque_app/src/shared/models/cardapio_item.dart';
import 'package:quiosque_app/src/shared/models/pagina_quiosque.dart';
import 'package:quiosque_app/src/shared/models/secao.dart';
import 'package:quiosque_app/src/shared/utils/formatters.dart';
import 'package:quiosque_app/src/shared/utils/imagem_remota.dart';

class CardapioInternoPage extends ConsumerStatefulWidget {
  const CardapioInternoPage({super.key});

  @override
  ConsumerState<CardapioInternoPage> createState() =>
      _CardapioInternoPageState();
}

class _CardapioInternoPageState extends ConsumerState<CardapioInternoPage> {
  // Id da seção selecionada no filtro; null = todas as categorias.
  String? _secaoSelecionada;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pagina =
        ref.watch(paginaQuiosqueProvider).value ?? const PaginaQuiosque();
    final qtdeCarrinho = ref.watch(carrinhoInternoProvider).length;

    // Garante que a seção selecionada ainda exista (pode ter sido removida).
    final secoes = pagina.secoes;
    final selecionadaValida =
        secoes.any((s) => s.id == _secaoSelecionada) ? _secaoSelecionada : null;
    final visiveis = selecionadaValida == null
        ? secoes
        : secoes.where((s) => s.id == selecionadaValida).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voltar'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/carrinhoInterno'),
        child: Badge(
          isLabelVisible: qtdeCarrinho > 0,
          label: Text('$qtdeCarrinho'),
          child: const Icon(Icons.shopping_cart),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (secoes.isNotEmpty) _filtroCategorias(theme, secoes, selecionadaValida),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    ...visiveis.map((secao) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text('${secao.nome}:',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ),
                            ...secao.itens.map((item) =>
                                _itemTile(context, theme, item)),
                          ],
                        )),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtroCategorias(
      ThemeData theme, List<Secao> secoes, String? selecionada) {
    Widget pill(String label, String? id) {
      final ativo = selecionada == id;
      return GestureDetector(
        onTap: () => setState(() => _secaoSelecionada = id),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: ativo
                ? theme.colorScheme.primary
                : theme.colorScheme.onTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ativo
                  ? theme.colorScheme.onTertiary
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            pill('Todos', null),
            ...secoes.map((s) => pill(s.nome, s.id)),
          ],
        ),
      ),
    );
  }

  Widget _itemTile(BuildContext context, ThemeData theme, CardapioItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/itemSelecao', extra: item),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: provedorImagem(item.imgPath) != null
                        ? Image(
                            image: provedorImagem(item.imgPath)!,
                            fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.fastfood,
                                color: theme.colorScheme.outline)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nome,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      if (item.descricao.isNotEmpty)
                        Text(item.descricao,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                Text(formatarPreco(item.preco),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
