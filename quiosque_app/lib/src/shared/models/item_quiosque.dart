import 'package:quiosque_app/src/shared/models/adicionaisItem.dart';

class ItemQuiosque {
  final String idItem;
  final String idQuiosque;
  final String secaoItem;
  final String nomeItem;
  final String descricaoItem;
  final int precoItem;
  final String imgItem;
  final bool disponivel;
  final List<String> ingredientes;
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



}