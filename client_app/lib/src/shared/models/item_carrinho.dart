import 'package:client_app/src/shared/models/adicionaisItem.dart';
import 'package:client_app/src/shared/models/ingrediente_item.dart';
import 'package:equatable/equatable.dart';

class ItemCarrinho extends Equatable{
  final String idProduto;
  final String idQuiosque;
  final String nomeItem;
  final int valorTotal;
  /// Ingredientes a remover do item neste pedido (com id + nome).
  final List<IngredienteItem> ingredientes;
  final List<AdicionaisItem> adicionais;
  final int qtdeItem;

  const ItemCarrinho({
    required this.idProduto,
    required this.idQuiosque,
    required this.nomeItem,
    required this.valorTotal,
    this.ingredientes = const [],
    this.adicionais = const [],
    this.qtdeItem = 1,
  });

  ItemCarrinho copyWith({
    String? idProduto,
    String? idQuiosque,
    String? nomeItem,
    int? valorTotal,
    List<IngredienteItem>? ingredientes,
    List<AdicionaisItem>? adicionais,
    int? qtdeItem,
  }) {
    return ItemCarrinho(
      idProduto: idProduto ?? this.idProduto,
      idQuiosque: idQuiosque ?? this.idQuiosque,
      nomeItem: nomeItem ?? this.nomeItem,
      valorTotal: valorTotal ?? this.valorTotal,
      ingredientes: ingredientes ?? this.ingredientes,
      adicionais: adicionais ?? this.adicionais,
      qtdeItem: qtdeItem ?? this.qtdeItem,
    );
  }

  @override
  @override
  List<Object?> get props => [
    idProduto,
    idQuiosque,
    ingredientes,
    adicionais,
  ];
}

class QuiosqueCarrinho extends Equatable{
  final String idQuiosque;
  final String nomeQuiosque;
  final String? imgBannerQuiosque;

  QuiosqueCarrinho({
    required this.idQuiosque,
    required this.nomeQuiosque,
    required this.imgBannerQuiosque,
  });

  @override
  List<Object?> get props => [idQuiosque];

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //         other is QuiosqueCarrinho && runtimeType == other.runtimeType && idQuiosque == other.idQuiosque;
  //
  // @override
  // int get hashCode => idQuiosque.hashCode;
}