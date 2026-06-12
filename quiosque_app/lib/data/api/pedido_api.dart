import 'package:quiosque_app/data/api/api_client.dart';
import 'package:quiosque_app/data/api/models/pedido_models.dart';

class PedidoApi {
  static final PedidoApi instance = PedidoApi._();

  PedidoApi._();

  final ApiClient _client = ApiClient.instance;

  List<PedidoView> _lista(dynamic resp) => (resp as List)
      .map((e) => PedidoView.fromJson(e as Map<String, dynamic>))
      .toList();

  // Cliente

  /// `GET /pedidos?status=` — pedidos do cliente (CLIENTE).
  Future<List<PedidoView>> meusPedidos({StatusPedidoApi? status}) async {
    final resp = await _client.get('/pedidos',
        query: {if (status != null) 'status': status.wire});
    return _lista(resp);
  }

  /// `GET /pedidos/ativos` — pedidos ativos do cliente (CLIENTE).
  Future<List<PedidoView>> meusPedidosAtivos() async {
    return _lista(await _client.get('/pedidos/ativos'));
  }

  /// `POST /pedidos` — cria um pedido (FUNCIONARIO ou CLIENTE).
  Future<PedidoView> criar(PedidoRequest pedido) async {
    final resp = await _client.post('/pedidos', body: pedido.toJson());
    return PedidoView.fromJson(resp as Map<String, dynamic>);
  }

  /// `POST /pedidos/{id}/cancelar` — cancela um pedido; retorna a mensagem.
  Future<String> cancelar(String id) async {
    final resp = await _client.post('/pedidos/$id/cancelar');
    return resp is String ? resp : '$resp';
  }

  /// `GET /pedidos/{id}/codigo` — código de verificação do pedido (CLIENTE).
  Future<String?> obterCodigo(String id) async {
    final resp = await _client.get('/pedidos/$id/codigo');
    return (resp as Map)['codigo'] as String?;
  }

  /// `POST /pedidos/{id}/avaliar` — avalia o pedido (nota de 1 a 5).
  Future<String> avaliar(String id, int nota) async {
    final resp = await _client.post('/pedidos/$id/avaliar', body: {'nota': nota});
    return resp is String ? resp : '$resp';
  }

  // Quiosque / Entregador

  /// `GET /pedidos/{id}` — detalhe de um pedido (FUNCIONARIO).
  Future<PedidoView> buscarPorId(String id) async {
    final resp = await _client.get('/pedidos/$id');
    return PedidoView.fromJson(resp as Map<String, dynamic>);
  }

  /// `POST /pedidos/{id}/validar-codigo` — valida o código de entrega.
  Future<bool> validarCodigo(String id, String codigo) async {
    final resp =
        await _client.post('/pedidos/$id/validar-codigo', body: {'codigo': codigo});
    return resp == true;
  }

  /// `POST /quiosques/me/pedidos/interno` — cria um pedido de balcão feito pelo
  /// próprio quiosque (FUNCIONARIO). Já nasce em PREPARANDO, sem código/entrega.
  Future<PedidoView> criarInterno(PedidoInternoRequest pedido) async {
    final resp = await _client.post('/quiosques/me/pedidos/interno',
        body: pedido.toJson());
    return PedidoView.fromJson(resp as Map<String, dynamic>);
  }

  /// `GET /quiosques/me/pedidos?status=` — pedidos do quiosque (FUNCIONARIO).
  Future<List<PedidoView>> doQuiosque({StatusPedidoApi? status}) async {
    final resp = await _client.get('/quiosques/me/pedidos',
        query: {if (status != null) 'status': status.wire});
    return _lista(resp);
  }

  /// `GET /quiosques/me/pedidos/ativos` — pedidos ativos do quiosque.
  Future<List<PedidoView>> doQuiosqueAtivos() async {
    return _lista(await _client.get('/quiosques/me/pedidos/ativos'));
  }

  /// `GET /quiosques/me/pedidos/entregar` — pedido designado para entrega.
  Future<PedidoView> paraEntregar() async {
    final resp = await _client.get('/quiosques/me/pedidos/entregar');
    return PedidoView.fromJson(resp as Map<String, dynamic>);
  }

  /// `POST /quiosques/me/pedidos/{id}/entregador` — assume a entrega do pedido.
  Future<PedidoView> assumirEntrega(String id) async {
    final resp = await _client.post('/quiosques/me/pedidos/$id/entregador');
    return PedidoView.fromJson(resp as Map<String, dynamic>);
  }

  /// `PATCH /quiosques/me/pedidos/{id}` — atualiza o status do pedido.
  /// O back-end pode responder sem corpo (204/200 vazio); nesse caso devolvemos
  /// `null`, pois o chamador apenas recarrega a lista após a troca.
  Future<PedidoView?> atualizarStatus(String id, StatusPedidoApi status) async {
    final resp = await _client
        .patch('/quiosques/me/pedidos/$id', body: {'status': status.wire});
    return resp is Map<String, dynamic> ? PedidoView.fromJson(resp) : null;
  }

  /// `PATCH /quiosques/me/pedidos/{id}/rejeitar` — rejeita o pedido.
  /// Pode responder sem corpo; devolvemos `null` nesse caso.
  Future<PedidoCreateResponse?> rejeitar(String id) async {
    final resp = await _client.patch('/quiosques/me/pedidos/$id/rejeitar');
    return resp is Map<String, dynamic>
        ? PedidoCreateResponse.fromJson(resp)
        : null;
  }

  /// `POST /quiosque/me/pedidos/{id}/cancelar` — cancela informando o motivo.
  /// (Atenção: o caminho usa `/quiosque/` no singular, conforme a API.)
  /// Pode responder sem corpo; devolvemos `null` nesse caso.
  Future<PedidoView?> cancelarComMotivo(String id, String motivo) async {
    final resp = await _client
        .post('/quiosque/me/pedidos/$id/cancelar', body: {'motivo': motivo});
    return resp is Map<String, dynamic> ? PedidoView.fromJson(resp) : null;
  }
}
