import 'package:quiosque_app/src/shared/models/adicionaisItem.dart';

class CardapioItem {
  final String id;
  final String nome;
  final String descricao;
  final String? imgPath;
  final int preco; // em centavos
  final List<String> ingredientes;
  // Id de cada ingrediente por nome (vindo da API). Usado para informar os
  // ingredientes removidos ao criar um pedido. Vazio para itens locais/novos.
  final Map<String, int> ingredientesIds;
  final List<AdicionaisItem> complementos;

  const CardapioItem({
    required this.id,
    required this.nome,
    this.descricao = '',
    this.imgPath,
    this.preco = 0,
    this.ingredientes = const [],
    this.ingredientesIds = const {},
    this.complementos = const [],
  });

  CardapioItem copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? imgPath,
    bool clearImg = false,
    int? preco,
    List<String>? ingredientes,
    Map<String, int>? ingredientesIds,
    List<AdicionaisItem>? complementos,
  }) {
    return CardapioItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      imgPath: clearImg ? null : (imgPath ?? this.imgPath),
      preco: preco ?? this.preco,
      ingredientes: ingredientes ?? this.ingredientes,
      ingredientesIds: ingredientesIds ?? this.ingredientesIds,
      complementos: complementos ?? this.complementos,
    );
  }
}
