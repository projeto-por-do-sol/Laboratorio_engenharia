import 'dart:convert';

class ItemPedidoRecebido {
  final String nome;
  final int qtde;
  final int valorUnitario; // centavos
  final List<String> ingredientesRemovidos;
  final List<String> complementos;
  // Ids usados apenas ao montar um pedido a partir do carrinho interno; vazios
  // para itens vindos de pedidos já criados (a API devolve só os nomes).
  final int? itemId;
  final List<int> acompanhamentosId;
  final List<int> ingredientesId;

  const ItemPedidoRecebido({
    required this.nome,
    this.qtde = 1,
    this.valorUnitario = 0,
    this.ingredientesRemovidos = const [],
    this.complementos = const [],
    this.itemId,
    this.acompanhamentosId = const [],
    this.ingredientesId = const [],
  });

  int get subtotal => valorUnitario * qtde;

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'qtde': qtde,
        'valorUnitario': valorUnitario,
        'ingredientesRemovidos': ingredientesRemovidos,
        'complementos': complementos,
      };

  factory ItemPedidoRecebido.fromMap(Map<String, dynamic> map) {
    return ItemPedidoRecebido(
      nome: map['nome'] as String,
      qtde: (map['qtde'] as int?) ?? 1,
      valorUnitario: (map['valorUnitario'] as int?) ?? 0,
      ingredientesRemovidos:
          (map['ingredientesRemovidos'] as List?)?.cast<String>() ?? const [],
      complementos: (map['complementos'] as List?)?.cast<String>() ?? const [],
    );
  }
}

class PedidoRecebido {
  final String id;
  final String nomeCliente;
  final String hora; // ISO 8601
  final String status; // aceitar, aceito, preparando, entregando, finalizado, cancelado
  final String codigo;
  final List<ItemPedidoRecebido> itens;
  /// Pedido feito pelo próprio quiosque (balcão): não possui código de
  /// verificação nem localização do cliente.
  final bool interno;
  // Localização de onde o pedido foi criado (vinda do back-end). Pedidos feitos
  // pelo próprio quiosque (balcão) não possuem localização.
  final double? clienteLat;
  final double? clienteLng;

  const PedidoRecebido({
    required this.id,
    required this.nomeCliente,
    required this.hora,
    required this.status,
    required this.codigo,
    required this.itens,
    this.interno = false,
    this.clienteLat,
    this.clienteLng,
  });

  int get total => itens.fold(0, (soma, i) => soma + i.subtotal);

  DateTime get horaDateTime =>
      DateTime.tryParse(hora) ?? DateTime.now();

  bool get temLocalizacao => clienteLat != null && clienteLng != null;

  PedidoRecebido copyWith({String? status}) {
    return PedidoRecebido(
      id: id,
      nomeCliente: nomeCliente,
      hora: hora,
      status: status ?? this.status,
      codigo: codigo,
      itens: itens,
      interno: interno,
      clienteLat: clienteLat,
      clienteLng: clienteLng,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nomeCliente': nomeCliente,
        'hora': hora,
        'status': status,
        'codigo': codigo,
        'itens': jsonEncode(itens.map((i) => i.toMap()).toList()),
        'clienteLat': clienteLat,
        'clienteLng': clienteLng,
      };

  factory PedidoRecebido.fromMap(Map<String, dynamic> map) {
    final itensJson = jsonDecode(map['itens'] as String) as List;
    return PedidoRecebido(
      id: map['id'] as String,
      nomeCliente: map['nomeCliente'] as String,
      hora: map['hora'] as String,
      status: map['status'] as String,
      codigo: map['codigo'] as String,
      itens: itensJson
          .map((e) => ItemPedidoRecebido.fromMap(e as Map<String, dynamic>))
          .toList(),
      clienteLat: (map['clienteLat'] as num?)?.toDouble(),
      clienteLng: (map['clienteLng'] as num?)?.toDouble(),
    );
  }
}
