import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/src/shared/models/pedidos_model.dart';

/// Acesso remoto aos pedidos do cliente (`ENDPOINTS.md` › Pedidos — Cliente).
class PedidoRepository {
  static final PedidoRepository instance = PedidoRepository._init();

  final ApiClient _api = ApiClient.instance;

  PedidoRepository._init();

  /// `GET /pedidos/ativos` — pedidos em andamento.
  Future<List<PedidosModel>> listarPedidosAtivos() async {
    final resp = await _api.get('/pedidos/ativos');
    return _extrairPedidos(resp);
  }

  /// `GET /pedidos?status=` — histórico de pedidos (todos por padrão).
  Future<List<PedidosModel>> listarPedidos({String? status}) async {
    final resp = await _api.get(
      '/pedidos',
      query: {if (status != null) 'status': status},
    );
    return _extrairPedidos(resp);
  }

  /// `POST /pedidos` — cria um pedido a partir do `body` montado pelo provider.
  Future<void> criarPedido(Map<String, dynamic> body) async {
    await _api.post('/pedidos', body: body);
  }

  /// `POST /pedidos/{id}/cancelar` — cancelamento pelo cliente.
  Future<void> cancelarPedido(String idPedido, {String? motivo}) async {
    await _api.post(
      '/pedidos/$idPedido/cancelar',
      body: {if (motivo != null) 'motivo': motivo},
    );
  }

  /// `GET /pedidos/{id}/codigo` — código de 4 dígitos do pedido.
  Future<String?> obterCodigo(String idPedido) async {
    final resp = await _api.get('/pedidos/$idPedido/codigo');
    if (resp is Map) {
      return (resp['codigoPedido'] ?? resp['codigo'] ?? resp['code'])
          ?.toString();
    }
    return resp?.toString();
  }

  /// `POST /pedidos/{id}/avaliar` — envia a avaliação (nota 1–5).
  Future<void> avaliarPedido(String idPedido, {required int nota}) async {
    await _api.post('/pedidos/$idPedido/avaliar', body: {'nota': nota});
  }

  /// `GET /pedidos/{id}` — busca um pedido específico (fallback de notificação).
  /// Retorna `null` em `404`.
  Future<PedidosModel?> buscarPedido(String idPedido) async {
    try {
      final resp = await _api.get('/pedidos/$idPedido');
      return PedidosModel.fromJson((resp as Map).cast<String, dynamic>());
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  List<PedidosModel> _extrairPedidos(dynamic resp) {
    dynamic lista = resp;
    if (resp is Map) {
      lista = resp['content'] ?? resp['data'] ?? resp['pedidos'] ?? const [];
    }
    if (lista is! List) return const [];
    return lista
        .map((e) => PedidosModel.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
