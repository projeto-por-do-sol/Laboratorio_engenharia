import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';

final carrinhoInternoProvider =
    NotifierProvider<CarrinhoInternoNotifier, List<ItemPedidoRecebido>>(
        CarrinhoInternoNotifier.new);

/// Nome do cliente do pedido interno. Mantido fora do widget para que não se
/// perca ao sair e voltar à página do carrinho.
final nomeClienteInternoProvider =
    NotifierProvider<NomeClienteInternoNotifier, String>(
        NomeClienteInternoNotifier.new);

class NomeClienteInternoNotifier extends Notifier<String> {
  @override
  String build() => '';

  void definir(String nome) => state = nome;
}

class CarrinhoInternoNotifier extends Notifier<List<ItemPedidoRecebido>> {
  @override
  List<ItemPedidoRecebido> build() => const [];

  void adicionar(ItemPedidoRecebido item) => state = [...state, item];

  void removerEm(int index) {
    final nova = [...state]..removeAt(index);
    state = nova;
  }

  void limpar() => state = const [];

  int get total => state.fold(0, (soma, i) => soma + i.subtotal);
}
