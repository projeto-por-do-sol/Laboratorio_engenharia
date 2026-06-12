import 'package:client_app/src/shared/models/item_carrinho.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'carrinho_provider.g.dart';

// Map<String, ItemCarrinho> listaItens = {};
//
// @riverpod
// Map<String, ItemCarrinho> carrinho(ref) {
//   return listaItens;
// }

@Riverpod(keepAlive: true)
class CarrinhoNotifier extends _$CarrinhoNotifier{

  @override
  Map<QuiosqueCarrinho, List<ItemCarrinho>> build() {
    return {};
  }

  bool adicionarItem(QuiosqueCarrinho quiosque, ItemCarrinho item) {
    try {
      final novoMapa = Map<QuiosqueCarrinho, List<ItemCarrinho>>.from(state);

      final novaLista = List<ItemCarrinho>.from(
        novoMapa[quiosque] ?? [],
      );

      final indexExistente = novaLista.indexOf(item);

      if (indexExistente != -1) {
        final itemAntigo = novaLista[indexExistente];

        novaLista[indexExistente] = itemAntigo.copyWith(
          qtdeItem: itemAntigo.qtdeItem + item.qtdeItem,
        );
      } else {
        novaLista.add(item);
      }

      novoMapa[quiosque] = novaLista;
      state = {...novoMapa};

      return true;
    } catch (e) {
      return false;
    }
  }

  void removerItem(QuiosqueCarrinho quiosque, ItemCarrinho item) {
    if (!state.containsKey(quiosque)) return;

    final novoMapa = Map<QuiosqueCarrinho, List<ItemCarrinho>>.from(state);
    final novaLista = List<ItemCarrinho>.from(novoMapa[quiosque]!);

    novaLista.remove(item);
    novoMapa[quiosque] = novaLista;

    if (novaLista.isEmpty) {
      novoMapa.remove(quiosque);
    }

    state = novoMapa;
  }

  void removerQuiosque(QuiosqueCarrinho quiosque) {
    final novoMapa = Map<QuiosqueCarrinho, List<ItemCarrinho>>.from(state);
    novoMapa.remove(quiosque);
    state = novoMapa;
  }

  void limparCarrinho(){
    state = {};
  }
}