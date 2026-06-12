import 'package:client_app/data/services/cliente_service.dart';
import 'package:client_app/data/services/pedido_service.dart';
import 'package:client_app/providers/carrinho_provider/carrinho_provider.dart';
import 'package:client_app/providers/cliente_provider/cliente_provider.dart';
import 'package:client_app/providers/historico_provider/historico_provider.dart';
import 'package:client_app/src/shared/models/pedidos_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pedido_provider.g.dart';

@Riverpod(keepAlive: true)
class PedidoNotifier extends _$PedidoNotifier {
  @override
  FutureOr<List<PedidosModel>> build() async {
    // Sem usuário logado não há pedidos a buscar: evita chamar o back-end
    // (que responderia 401/403) enquanto deslogado. Reage ao login/logout.
    final cliente = await ref.watch(clienteProvider.future);
    if (cliente == null) return [];

    final ativos = await PedidoService.instance.listarPedidosAtivos();
    // O código de retirada vem de um endpoint separado (`/pedidos/{id}/codigo`);
    // enriquece cada pedido ativo com ele para exibir na tela de pedidos.
    return Future.wait(ativos.map((pedido) async {
      try {
        final codigo = await PedidoService.instance.obterCodigo(pedido.idPedido);
        if (codigo != null && codigo.isNotEmpty) {
          return pedido.copyWith(codigoPedido: codigo);
        }
      } catch (_) {/* sem código disponível: mantém o pedido como está */}
      return pedido;
    }));
  }

  /// Cria os pedidos do carrinho no back-end (`POST /pedidos`, um por quiosque)
  /// e recarrega a lista de pedidos ativos.
  ///
  /// O back-end (`PedidoDTO`) exige a coordenada de entrega e valida se ela
  /// está no raio/horário do quiosque — usamos a localização do dispositivo.
  Future<bool> criarPedido() async {
    final carrinho = ref.read(carrinhoProvider);
    if (carrinho.isEmpty) return false;

    final posicao = await ClienteService.instance.obterLocalizacao();
    if (posicao == null) {
      print("Erro ao criar pedido: localização indisponível");
      return false;
    }

    try {
      for (final entry in carrinho.entries) {
        final quiosque = entry.key;
        final itens = entry.value;

        final body = {
          'quiosque': int.tryParse(quiosque.idQuiosque) ?? quiosque.idQuiosque,
          'itens': itens
              .map((item) => {
                    'itemId': int.tryParse(item.idProduto) ?? item.idProduto,
                    'quantidade': item.qtdeItem,
                    // IDs dos acompanhamentos a incluir e dos ingredientes a
                    // remover, conforme selecionado na tela do item.
                    'acompanhamentosid':
                        item.adicionais.map((a) => a.id).toList(),
                    'ingredientesid':
                        item.ingredientes.map((i) => i.id).toList(),
                  })
              .toList(),
          'latitudeEntrega': posicao.latitude,
          'longitudeEntrega': posicao.longitude,
          'codigoEntrega': null,
        };

        await PedidoService.instance.criarPedido(body);
      }

      ref.read(carrinhoProvider.notifier).limparCarrinho();
      ref.invalidateSelf();
      return true;
    } catch (e) {
      print("Erro ao criar pedido: $e");
      return false;
    }
  }

  /// Cancela um pedido (`POST /pedidos/{id}/cancelar`) e recarrega a lista.
  /// Também invalida o histórico para o pedido cancelado aparecer lá.
  Future<void> cancelarPedido(String idPedido, {String? motivo}) async {
    await PedidoService.instance.cancelarPedido(idPedido, motivo: motivo);
    ref.invalidateSelf();
    ref.invalidate(historicoProvider);
  }

  /// Avalia um pedido finalizado (`POST /pedidos/{id}/avaliar`).
  Future<void> avaliarPedido(String idPedido, int nota) async {
    await PedidoService.instance.avaliarPedido(idPedido, nota: nota);
    ref.invalidate(historicoProvider);
  }

  /// Busca um pedido no back-end (usado quando ele não está em memória).
  Future<PedidosModel?> buscarPedidoNoBackend(String idPedido) =>
      PedidoService.instance.buscarPedidoNoBackend(idPedido);

  /// Limpa a lista em memória (ex.: logout). Não apaga nada no back-end.
  void apagarPedidos() {
    state = const AsyncData([]);
  }

  /// Recarrega a lista de pedidos ativos do back-end.
  void recarregar() => ref.invalidateSelf();
}
