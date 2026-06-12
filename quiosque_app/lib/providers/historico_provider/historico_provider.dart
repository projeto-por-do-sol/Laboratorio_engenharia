import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiosque_app/data/api/models/pedido_models.dart';
import 'package:quiosque_app/data/api/pedido_api.dart';
import 'package:quiosque_app/src/shared/models/adicionaisItem.dart';
import 'package:quiosque_app/src/shared/models/item_carrinho.dart';
import 'package:quiosque_app/src/shared/models/pedidos_model.dart';

/// Histórico de pedidos do quiosque: pedidos já encerrados (finalizados,
/// avaliados, cancelados ou rejeitados), vindos de `GET /quiosques/me/pedidos`.
final historicoProvider =
    AsyncNotifierProvider<HistoricoNotifier, List<PedidosModel>>(
      HistoricoNotifier.new,
    );

class HistoricoNotifier extends AsyncNotifier<List<PedidosModel>> {
  @override
  Future<List<PedidosModel>> build() => _carregarHistorico();

  Future<List<PedidosModel>> _carregarHistorico() async {
    final pedidos = await PedidoApi.instance.doQuiosque();
    return pedidos
        .where((p) => p.status.finalizado_)
        .map(_mapear)
        .toList();
  }

  PedidosModel _mapear(PedidoView p) => PedidosModel(
        idPedido: p.id,
        // A listagem não expõe o código de verificação do pedido.
        codigoPedido: '',
        quiosque: QuiosqueCarrinho(
          idQuiosque: '${p.idQuiosque}',
          nomeQuiosque: p.nomeQuiosque,
          imgBannerQuiosque: null,
        ),
        itens: p.itens.map((i) => _mapearItem(i, p.idCliente)).toList(),
        status: _statusLabel(p.status),
        horaPedido: (p.dataHoraPedido ?? DateTime.now()).toIso8601String(),
        nomeCliente: p.nomeCliente,
        horaFinalizacao: p.dataHoraEntrega?.toIso8601String(),
      );

  ItemCarrinho _mapearItem(ItemPedidoView i, int idCliente) {
    final subtotalCentavos = i.subTotal != null
        ? (i.subTotal! * 100).round()
        : ((i.valorUnit ?? 0) * 100).round() * i.quantidade;
    // Prefere os acompanhamentos com preço; cai para os nomes (sem valor)
    // apenas se a visão detalhada não vier.
    final adicionais = i.acompanhamentosDetalhe.isNotEmpty
        ? i.acompanhamentosDetalhe
            .map((a) => AdicionaisItem(
                  id: a.id,
                  nomeAdicional: a.nome,
                  precoAdicional: (a.valor * 100).round(),
                ))
            .toList()
        : i.acompanhamentos
            .map((n) => AdicionaisItem(nomeAdicional: n, precoAdicional: 0))
            .toList();
    return ItemCarrinho(
      idProduto: '${i.itemId}',
      idCliente: '$idCliente',
      nomeItem: i.nome ?? '',
      valorTotal: subtotalCentavos,
      qtdeItem: i.quantidade,
      ingredientes: i.ingredientesRemovidos,
      adicionais: adicionais,
    );
  }

  /// Rótulo exibido no histórico. "Finalizado" também aciona a exibição do
  /// valor total do pedido na tela.
  static String _statusLabel(StatusPedidoApi s) {
    switch (s) {
      case StatusPedidoApi.finalizado:
      case StatusPedidoApi.avaliado:
        return 'Finalizado';
      case StatusPedidoApi.cancelado:
        return 'Cancelado';
      case StatusPedidoApi.rejeitado:
        return 'Rejeitado';
      default:
        return 'Finalizado';
    }
  }

  void refresh() => ref.invalidateSelf();
}
