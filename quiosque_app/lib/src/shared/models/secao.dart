import 'package:quiosque_app/src/shared/models/cardapio_item.dart';

class Secao {
  final String id;
  final String nome;
  final List<CardapioItem> itens;

  const Secao({
    required this.id,
    required this.nome,
    this.itens = const [],
  });

  Secao copyWith({
    String? id,
    String? nome,
    List<CardapioItem>? itens,
  }) {
    return Secao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      itens: itens ?? this.itens,
    );
  }
}
