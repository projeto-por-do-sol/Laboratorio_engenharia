class AdicionaisItem {
  /// Id do acompanhamento na API, quando já cadastrado. `null` para um
  /// complemento novo (ainda não enviado ao servidor).
  final int? id;
  final String nomeAdicional;
  final int precoAdicional;

  AdicionaisItem({
    this.id,
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
      id: (map['id'] as num?)?.toInt(),
      nomeAdicional: map['nome'] ?? '',
      precoAdicional: (map['preco'] as int?) ?? 0,
    );
  }

}
