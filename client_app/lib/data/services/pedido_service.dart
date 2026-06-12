import 'package:client_app/data/repositories/pedido_repository.dart';
import 'package:client_app/src/shared/models/pedidos_model.dart';

class PedidoService {
  static final PedidoService instance = PedidoService._init();

  final PedidoRepository _repository = PedidoRepository.instance;

  PedidoService._init();

  Future<List<PedidosModel>> listarPedidosAtivos() =>
      _repository.listarPedidosAtivos();

  Future<List<PedidosModel>> listarHistorico({String? status}) =>
      _repository.listarPedidos(status: status);

  Future<void> criarPedido(Map<String, dynamic> body) =>
      _repository.criarPedido(body);

  Future<void> cancelarPedido(String idPedido, {String? motivo}) =>
      _repository.cancelarPedido(idPedido, motivo: motivo);

  Future<String?> obterCodigo(String idPedido) =>
      _repository.obterCodigo(idPedido);

  Future<void> avaliarPedido(String idPedido, {required int nota}) =>
      _repository.avaliarPedido(idPedido, nota: nota);

  /// Busca um pedido específico no back-end (`GET /pedidos/{id}`).
  /// Usado quando o pedido referido por uma notificação não está em memória.
  Future<PedidosModel?> buscarPedidoNoBackend(String idPedido) =>
      _repository.buscarPedido(idPedido);
}
