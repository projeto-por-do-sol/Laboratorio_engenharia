import 'package:equatable/equatable.dart';

class AdicionaisItem extends Equatable {
  /// Id do acompanhamento no back-end. Necessário para enviar
  /// `ItemPedidoDTO.acompanhamentosid` ao criar o pedido.
  final int id;
  final String nomeAdicional;
  final int precoAdicional;

  const AdicionaisItem({
    this.id = 0,
    required this.nomeAdicional,
    required this.precoAdicional,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nomeAdicional,
      'preco': precoAdicional,
    };
  }

  factory AdicionaisItem.fromMap(Map<String, dynamic> map) {
    return AdicionaisItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      nomeAdicional: (map['nome'] ?? '').toString(),
      precoAdicional: _precoEmCentavos(map),
    );
  }

  /// O app trabalha com preço em centavos (int). O back-end
  /// (`AcompanhamentoViewDTO`) manda `valor` em reais (decimal); o contrato
  /// antigo manda `preco` em centavos.
  static int _precoEmCentavos(Map<String, dynamic> map) {
    if (map['preco'] != null) return (map['preco'] as num).toInt();
    final valor = map['valor'] as num?;
    if (valor == null) return 0;
    return (valor.toDouble() * 100).round();
  }

  @override
  List<Object?> get props => [id, nomeAdicional, precoAdicional];
}
