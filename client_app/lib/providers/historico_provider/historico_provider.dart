import 'package:client_app/data/services/pedido_service.dart';
import 'package:client_app/providers/cliente_provider/cliente_provider.dart';
import 'package:client_app/src/shared/models/pedidos_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historicoProvider =
    AsyncNotifierProvider<HistoricoNotifier, List<PedidosModel>>(
      HistoricoNotifier.new,
    );

class HistoricoNotifier extends AsyncNotifier<List<PedidosModel>> {
  @override
  Future<List<PedidosModel>> build() async {
    // Sem usuário logado não há histórico a buscar: evita o `GET /pedidos`
    // (401/403) enquanto deslogado. Reage ao login/logout.
    final cliente = await ref.watch(clienteProvider.future);
    if (cliente == null) return [];

    // `GET /pedidos` — histórico completo de pedidos do cliente.
    return PedidoService.instance.listarHistorico();
  }

  void refresh() => ref.invalidateSelf();
}
