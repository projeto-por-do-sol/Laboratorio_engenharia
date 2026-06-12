import 'package:client_app/src/shared/models/adicionaisItem.dart';
import 'package:client_app/src/shared/models/ingrediente_item.dart';

class ItemQuiosque {
  final String idItem;
  final String idQuiosque;
  final String secaoItem;
  final String nomeItem;
  final String descricaoItem;
  final int precoItem;
  final String imgItem;
  final bool disponivel;
  final List<IngredienteItem> ingredientes;
  final List<AdicionaisItem> adicionais;
  int qtdeItem;

  ItemQuiosque({
    required this.idItem,
    required this.idQuiosque,
    required this.secaoItem,
    required this.nomeItem,
    required this.descricaoItem,
    required this.precoItem,
    required this.imgItem,
    required this.disponivel,
    this.qtdeItem = 0,
    required this.ingredientes,
    required this.adicionais,
  });

  factory ItemQuiosque.fromJson(Map<String, dynamic> json) {
    // Aceita tanto os nomes do app quanto os do back-end (ItemDTO:
    // id/nome/descricao/valorBase(reais)/imagem/ingredientes[{id,nome}]/acompanhamentos).
    return ItemQuiosque(
      idItem: (json['idItem'] ?? json['id'])?.toString() ?? '',
      idQuiosque: json['idQuiosque']?.toString() ?? '',
      secaoItem: (json['secaoItem'] ?? json['tipo'] ?? '').toString(),
      nomeItem: (json['nomeItem'] ?? json['nome'] ?? '').toString(),
      descricaoItem: (json['descricaoItem'] ?? json['descricao'] ?? '').toString(),
      precoItem: _precoEmCentavos(json),
      imgItem: (json['imgItem'] ?? json['imagem'] ?? '').toString(),
      disponivel: json['disponivel'] ?? true,
      qtdeItem: (json['qtdeItem'] as num?)?.toInt() ?? 0,
      ingredientes: ((json['ingredientes'] as List?) ?? const [])
          .map((e) => e is Map
              ? IngredienteItem.fromMap(e.cast<String, dynamic>())
              : IngredienteItem(id: 0, nome: e.toString()))
          .where((i) => i.nome.isNotEmpty)
          .toList(),
      adicionais: ((json['adicionais'] ?? json['acompanhamentos']) as List?)
              ?.map((e) => AdicionaisItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// O app trabalha com preço em centavos (int); o back-end manda `valorBase`/
  /// `valorPromo` em reais (decimal). Converte quando necessário.
  static int _precoEmCentavos(Map<String, dynamic> json) {
    if (json['precoItem'] != null) return (json['precoItem'] as num).toInt();
    final valor = (json['valorPromo'] ?? json['valorBase']) as num?;
    if (valor == null) return 0;
    return (valor.toDouble() * 100).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'idItem': idItem,
      'idQuiosque': idQuiosque,
      'secaoItem': secaoItem,
      'nomeItem': nomeItem,
      'descricaoItem': descricaoItem,
      'precoItem': precoItem,
      'imgItem': imgItem,
      'disponivel': disponivel,
      'qtdeItem': qtdeItem,
      'ingredientes': ingredientes.map((e) => e.toJson()).toList(),
      'adicionais': adicionais.map((e) => e.toJson()).toList(),
    };
  }
}