import 'package:quiosque_app/data/repositories/pedido_repository.dart';

class PedidoService {
  static final PedidoService instance = PedidoService._init();

  final PedidoRepository _repository = PedidoRepository.instance;

  PedidoService._init();

  Future<List<Map<String, dynamic>>> listarPedidos() =>
      _repository.listarPedidos();

  Future<int> inserirItem(Map<String, dynamic> dadosPedido) =>
      _repository.inserirItem(dadosPedido);

  Future<int> atualizarStatus(String idPedido, String novoStatus) =>
      _repository.atualizarStatus(idPedido, novoStatus);

  Future<int> deletarTodosPedidos() => _repository.deletarPedido();

  Future<int> deletarPedidoPorId(String idPedido) =>
      _repository.deletarPedidoIdPedidoIdQuiosque(idPedido);

  Future<int> finalizarTodosPedidos() => _repository.finalizarTodos();
}
