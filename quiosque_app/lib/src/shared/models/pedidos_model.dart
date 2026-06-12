import 'package:quiosque_app/src/shared/models/item_carrinho.dart';

class PedidosModel {
  final String idPedido;
  final String codigoPedido;
  final QuiosqueCarrinho quiosque;
  final List<ItemCarrinho> itens;
  String status;
  String horaPedido;

  /// Nome do cliente (ou nome avulso, em pedidos de balcão).
  final String nomeCliente;

  /// Hora de finalização/entrega (ISO 8601). Nula enquanto não finalizado.
  final String? horaFinalizacao;

  PedidosModel({
    required this.idPedido,
    required this.codigoPedido,
    required this.quiosque,
    required this.itens,
    required this.status,
    required this.horaPedido,
    this.nomeCliente = '',
    this.horaFinalizacao,
  });
}