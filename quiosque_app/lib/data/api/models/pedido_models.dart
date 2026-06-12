// Modelos de pedido, espelhando `PedidoGetDTO`, `ItemPedidoGetDTO`,
// `PedidoCreateResponseDTO` e os corpos de requisição `PedidoDTO`/`ItemPedidoDTO`.

double _toDoubleOr(dynamic v, [double fallback = 0]) =>
    (v as num?)?.toDouble() ?? fallback;
int? _toInt(dynamic v) => (v as num?)?.toInt();

/// `StatusPedido` da API. O valor enviado/recebido (`wire`) é o nome em caixa
/// alta usado pelo back-end.
enum StatusPedidoApi {
  rejeitado('REJEITADO'),
  criado('CRIADO'),
  aceito('ACEITO'),
  preparando('PREPARANDO'),
  emEntrega('EM_ENTREGA'),
  finalizado('FINALIZADO'),
  avaliado('AVALIADO'),
  cancelado('CANCELADO');

  final String wire;
  const StatusPedidoApi(this.wire);

  static StatusPedidoApi fromWire(String? v) {
    return StatusPedidoApi.values.firstWhere(
      (s) => s.wire == v,
      orElse: () => StatusPedidoApi.criado,
    );
  }

  bool get finalizado_ => const [
        StatusPedidoApi.rejeitado,
        StatusPedidoApi.finalizado,
        StatusPedidoApi.avaliado,
        StatusPedidoApi.cancelado,
      ].contains(this);
}

/// Acompanhamento (adicional) de um item de pedido, com preço.
/// Espelha `AcompanhamentoPedidoDTO`.
class AcompanhamentoPedidoView {
  final int? id;
  final String nome;

  /// Preço do adicional (em reais).
  final double valor;

  const AcompanhamentoPedidoView({
    this.id,
    required this.nome,
    this.valor = 0,
  });

  factory AcompanhamentoPedidoView.fromJson(Map<String, dynamic> j) =>
      AcompanhamentoPedidoView(
        id: _toInt(j['id']),
        nome: j['nome'] as String? ?? '',
        valor: (j['valor'] as num?)?.toDouble() ?? 0,
      );
}

/// `ItemPedidoGetDTO` — linha de um pedido já criado.
class ItemPedidoView {
  final int itemId;
  final String? nome;
  final int quantidade;
  final double? subTotal;
  final double? valorUnit;

  /// Nomes dos acompanhamentos escolhidos.
  final List<String> acompanhamentos;

  /// Acompanhamentos escolhidos com nome e preço (`acompanhamentos` no DTO).
  final List<AcompanhamentoPedidoView> acompanhamentosDetalhe;

  /// Nomes dos ingredientes removidos.
  final List<String> ingredientesRemovidos;

  const ItemPedidoView({
    required this.itemId,
    this.nome,
    required this.quantidade,
    this.subTotal,
    this.valorUnit,
    this.acompanhamentos = const [],
    this.acompanhamentosDetalhe = const [],
    this.ingredientesRemovidos = const [],
  });

  factory ItemPedidoView.fromJson(Map<String, dynamic> j) => ItemPedidoView(
        itemId: (j['itemId'] as num).toInt(),
        nome: j['nome'] as String?,
        quantidade: _toInt(j['quantidade']) ?? 1,
        subTotal: (j['subTotal'] as num?)?.toDouble(),
        valorUnit: (j['valorUnit'] as num?)?.toDouble(),
        acompanhamentos: ((j['acompanhamentosid'] as List?) ?? const [])
            .map((e) => '$e')
            .toList(),
        acompanhamentosDetalhe: ((j['acompanhamentos'] as List?) ?? const [])
            .map((e) =>
                AcompanhamentoPedidoView.fromJson(e as Map<String, dynamic>))
            .toList(),
        ingredientesRemovidos: ((j['ingredientesid'] as List?) ?? const [])
            .map((e) => '$e')
            .toList(),
      );
}

/// `PedidoGetDTO` — pedido completo.
class PedidoView {
  final String id;
  final int idQuiosque;
  final String nomeQuiosque;
  final int idCliente;
  final String nomeCliente;
  final int? idEntregador;
  final String? nomeEntregador;
  final double valorTotal;
  final DateTime? dataHoraPedido;

  /// Momento em que o pedido foi finalizado/entregue. Nulo enquanto não
  /// finalizado.
  final DateTime? dataHoraEntrega;
  final int? tempoEstimado;
  final List<ItemPedidoView> itens;
  final double latitudeEntrega;
  final double longitudeEntrega;
  final StatusPedidoApi status;
  final String? motivo;

  /// Pedido de balcão feito pelo próprio quiosque (sem entrega/código).
  final bool interno;

  const PedidoView({
    required this.id,
    required this.idQuiosque,
    required this.nomeQuiosque,
    required this.idCliente,
    required this.nomeCliente,
    this.idEntregador,
    this.nomeEntregador,
    required this.valorTotal,
    this.dataHoraPedido,
    this.dataHoraEntrega,
    this.tempoEstimado,
    this.itens = const [],
    this.latitudeEntrega = 0,
    this.longitudeEntrega = 0,
    required this.status,
    this.motivo,
    this.interno = false,
  });

  factory PedidoView.fromJson(Map<String, dynamic> j) => PedidoView(
        id: '${j['id']}',
        idQuiosque: _toInt(j['id_quiosque']) ?? 0,
        nomeQuiosque: j['nome_quiosque'] as String? ?? '',
        idCliente: _toInt(j['id_cliente']) ?? 0,
        nomeCliente: j['nome_cliente'] as String? ?? '',
        idEntregador: _toInt(j['id_entregador']),
        nomeEntregador: j['nome_entregador'] as String?,
        valorTotal: _toDoubleOr(j['valorTotal']),
        dataHoraPedido: j['dataHoraPedido'] is String
            ? DateTime.tryParse(j['dataHoraPedido'] as String)
            : null,
        dataHoraEntrega: j['dataHoraEntrega'] is String
            ? DateTime.tryParse(j['dataHoraEntrega'] as String)
            : null,
        tempoEstimado: _toInt(j['tempoEstimado']),
        itens: ((j['itens'] as List?) ?? const [])
            .map((e) => ItemPedidoView.fromJson(e as Map<String, dynamic>))
            .toList(),
        latitudeEntrega: _toDoubleOr(j['latitudeEntrega']),
        longitudeEntrega: _toDoubleOr(j['longitudeEntrega']),
        status: StatusPedidoApi.fromWire(j['status'] as String?),
        motivo: j['motivo'] as String?,
        interno: j['interno'] as bool? ?? false,
      );
}

/// `PedidoCreateResponseDTO` — resposta enxuta de criação/rejeição de pedido.
class PedidoCreateResponse {
  final String id;
  final double valorTotal;
  final DateTime? dataHoraPedido;
  final int? tempoEstimado;
  final String? quiosque;
  final String? entregador;
  final StatusPedidoApi status;

  const PedidoCreateResponse({
    required this.id,
    required this.valorTotal,
    this.dataHoraPedido,
    this.tempoEstimado,
    this.quiosque,
    this.entregador,
    required this.status,
  });

  factory PedidoCreateResponse.fromJson(Map<String, dynamic> j) => PedidoCreateResponse(
        id: '${j['id']}',
        valorTotal: _toDoubleOr(j['valorTotal']),
        dataHoraPedido: j['dataHoraPedido'] is String
            ? DateTime.tryParse(j['dataHoraPedido'] as String)
            : null,
        tempoEstimado: _toInt(j['tempoEstimado']),
        quiosque: j['quiosque'] as String?,
        entregador: j['entregador'] as String?,
        status: StatusPedidoApi.fromWire(j['status'] as String?),
      );
}

/// `ItemPedidoDTO` — linha de um pedido a ser criado.
class ItemPedidoRequest {
  final int itemId;
  final int quantidade;
  final List<int> acompanhamentosId;
  final List<int> ingredientesId;

  const ItemPedidoRequest({
    required this.itemId,
    required this.quantidade,
    this.acompanhamentosId = const [],
    this.ingredientesId = const [],
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'quantidade': quantidade,
        'acompanhamentosid': acompanhamentosId,
        'ingredientesid': ingredientesId,
      };
}

/// `PedidoDTO` — corpo de criação de pedido (`POST /pedidos`).
class PedidoRequest {
  final int quiosque;
  final List<ItemPedidoRequest> itens;
  final double latitudeEntrega;
  final double longitudeEntrega;
  final String? codigoEntrega;

  const PedidoRequest({
    required this.quiosque,
    required this.itens,
    required this.latitudeEntrega,
    required this.longitudeEntrega,
    this.codigoEntrega,
  });

  Map<String, dynamic> toJson() => {
        'quiosque': quiosque,
        'itens': itens.map((e) => e.toJson()).toList(),
        'latitudeEntrega': latitudeEntrega,
        'longitudeEntrega': longitudeEntrega,
        'codigoEntrega': ?codigoEntrega,
      };
}

/// `PedidoInternoDTO` — corpo de criação de um pedido de balcão
/// (`POST /quiosques/me/pedidos/interno`). Sem quiosque/coordenadas: o servidor
/// resolve o quiosque pelo funcionário autenticado.
class PedidoInternoRequest {
  final List<ItemPedidoRequest> itens;

  /// Nome avulso para identificar o pedido no balcão. Quando vazio, a API
  /// assume "Balcão".
  final String? nomeCliente;

  const PedidoInternoRequest({required this.itens, this.nomeCliente});

  Map<String, dynamic> toJson() => {
        'itens': itens.map((e) => e.toJson()).toList(),
        if (nomeCliente != null && nomeCliente!.isNotEmpty)
          'nomeCliente': nomeCliente,
      };
}
