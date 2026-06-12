import 'package:equatable/equatable.dart';

/// Ingrediente de um item do cardápio. Mantém o `id` — necessário para informar
/// ao back-end (`ItemPedidoDTO.ingredientesid`) quais ingredientes remover no
/// pedido — além do `nome`, usado para exibição.
class IngredienteItem extends Equatable {
  final int id;
  final String nome;

  const IngredienteItem({required this.id, required this.nome});

  /// Aceita a forma do back-end (`IngredienteDTO`: `{id, nome}`) e, como
  /// fallback, apenas o nome (ex.: pedidos já criados, onde o back-end devolve
  /// somente os nomes dos ingredientes removidos).
  factory IngredienteItem.fromMap(Map<String, dynamic> map) {
    return IngredienteItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      nome: (map['nome'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};

  @override
  List<Object?> get props => [id, nome];
}
