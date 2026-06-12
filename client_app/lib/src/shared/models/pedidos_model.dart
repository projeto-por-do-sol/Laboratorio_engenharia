import 'package:client_app/src/shared/models/adicionaisItem.dart';
import 'package:client_app/src/shared/models/ingrediente_item.dart';
import 'package:client_app/src/shared/models/item_carrinho.dart';

class PedidosModel {
  final String idPedido;
  final String codigoPedido;
  final QuiosqueCarrinho quiosque;
  final List<ItemCarrinho> itens;

  /// Status "cru" do back-end (enum): CRIADO, PREPARANDO, EM_ENTREGA,
  /// FINALIZADO, AVALIADO, REJEITADO, CANCELADO.
  final String statusRaw;
  String horaPedido;
  String? motivoCancelamento;

  /// Nota da avaliação do cliente (1..5); nula enquanto não avaliado.
  final int? nota;

  /// Momento em que o pedido entrou em PREPARANDO. Base da janela de 30 min
  /// para o cliente poder cancelar. Nulo enquanto CRIADO.
  final DateTime? dataHoraPreparando;

  PedidosModel({
    required this.idPedido,
    required this.codigoPedido,
    required this.quiosque,
    required this.itens,
    required this.statusRaw,
    required this.horaPedido,
    this.motivoCancelamento,
    this.nota,
    this.dataHoraPreparando,
  });

  PedidosModel copyWith({String? codigoPedido}) {
    return PedidosModel(
      idPedido: idPedido,
      codigoPedido: codigoPedido ?? this.codigoPedido,
      quiosque: quiosque,
      itens: itens,
      statusRaw: statusRaw,
      horaPedido: horaPedido,
      motivoCancelamento: motivoCancelamento,
      nota: nota,
      dataHoraPreparando: dataHoraPreparando,
    );
  }

  /// Janela de cancelamento para pedidos em PREPARANDO/EM_ENTREGA: 30 min após
  /// entrar em preparo. Nula enquanto não há `dataHoraPreparando`.
  static const Duration janelaCancelamento = Duration(minutes: 30);

  /// Quando o cliente poderá cancelar (30 min após PREPARANDO). Nulo se ainda
  /// não entrou em preparo.
  DateTime? get liberaCancelamentoEm =>
      dataHoraPreparando?.add(janelaCancelamento);

  /// Tempo restante até poder cancelar; `Duration.zero` se já liberou. Nulo se
  /// não se aplica (pedido não está em preparo/entrega ou sem marco).
  Duration? get tempoParaCancelar {
    if (statusRaw != 'PREPARANDO' && statusRaw != 'EM_ENTREGA') return null;
    final libera = liberaCancelamentoEm;
    if (libera == null) return null;
    final restante = libera.difference(DateTime.now());
    return restante.isNegative ? Duration.zero : restante;
  }

  /// Se o cliente já pode cancelar agora: CRIADO sempre; PREPARANDO/EM_ENTREGA
  /// apenas depois da janela de 30 min.
  bool get podeCancelarAgora {
    if (statusRaw == 'CRIADO') return true;
    if (statusRaw == 'PREPARANDO' || statusRaw == 'EM_ENTREGA') {
      return (tempoParaCancelar ?? Duration.zero) == Duration.zero;
    }
    return false;
  }

  /// Rótulo em português para exibição.
  String get status => labelStatus(statusRaw);

  bool get cancelado => statusRaw == 'CANCELADO' || statusRaw == 'REJEITADO';
  bool get finalizado => statusRaw == 'FINALIZADO' || statusRaw == 'AVALIADO';
  bool get podeAvaliar => statusRaw == 'FINALIZADO';
  bool get jaAvaliado => statusRaw == 'AVALIADO';
  bool get ativo => !cancelado && !finalizado;

  static String labelStatus(String raw) {
    switch (raw) {
      case 'CRIADO':
        return 'Aguardando confirmação';
      case 'PREPARANDO':
        return 'Preparando';
      case 'EM_ENTREGA':
        return 'Entregando';
      case 'FINALIZADO':
        return 'Finalizado';
      case 'AVALIADO':
        return 'Avaliado';
      case 'REJEITADO':
        return 'Rejeitado pelo quiosque';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return raw;
    }
  }

  /// Aceita tanto a forma "aninhada" (contrato antigo) quanto a forma "plana"
  /// do back-end real (`PedidoGetDTO`: id/id_quiosque/nome_quiosque/
  /// itens[{itemId,nome,quantidade,subTotal,valorUnit,ingredientesid,...}]/
  /// status(enum)/dataHoraPedido/motivo).
  factory PedidosModel.fromJson(Map<String, dynamic> json) {
    final idQuiosque =
        (json['id_quiosque'] ?? (json['quiosque'] as Map?)?['idQuiosque'])
            ?.toString() ??
            '';

    final quiosqueJson = json['quiosque'];
    final quiosque = quiosqueJson is Map
        ? QuiosqueCarrinho(
            idQuiosque: quiosqueJson['idQuiosque']?.toString() ?? '',
            nomeQuiosque: (quiosqueJson['nomeQuiosque'] ?? '').toString(),
            imgBannerQuiosque: quiosqueJson['imgBannerQuiosque'],
          )
        : QuiosqueCarrinho(
            idQuiosque: idQuiosque,
            nomeQuiosque: (json['nome_quiosque'] ?? '').toString(),
            imgBannerQuiosque: json['imgBannerQuiosque'],
          );

    final itensJson = (json['itens'] as List?) ?? const [];

    return PedidosModel(
      idPedido: (json['idPedido'] ?? json['id'])?.toString() ?? '',
      codigoPedido:
          (json['codigoPedido'] ?? json['codigo'] ?? '').toString(),
      statusRaw: (json['status'] ?? '').toString(),
      horaPedido:
          (json['horaPedido'] ?? json['dataHoraPedido'] ?? '').toString(),
      motivoCancelamento:
          (json['motivoCancelamento'] ?? json['motivo']) as String?,
      nota: (json['nota'] as num?)?.toInt(),
      dataHoraPreparando: json['dataHoraPreparando'] != null
          ? DateTime.tryParse(json['dataHoraPreparando'].toString())
          : null,
      quiosque: quiosque,
      itens: itensJson.map((itemJson) {
        final item = itemJson as Map<String, dynamic>;
        return ItemCarrinho(
          idProduto: (item['idProduto'] ?? item['itemId'])?.toString() ?? '',
          idQuiosque: (item['idQuiosque'] ?? idQuiosque).toString(),
          nomeItem: (item['nomeItem'] ?? item['nome'] ?? 'Item').toString(),
          valorTotal: _valorEmCentavos(item),
          qtdeItem: (item['qtdeItem'] ?? item['quantidade'] ?? 1) as int,
          ingredientes: ((item['ingredientes'] ?? item['ingredientesid'])
                      as List?)
                  ?.map((e) => e is Map
                      ? IngredienteItem.fromMap(e.cast<String, dynamic>())
                      : IngredienteItem(id: 0, nome: e.toString()))
                  .where((i) => i.nome.isNotEmpty)
                  .toList() ??
              const [],
          adicionais: _parseAdicionais(item),
        );
      }).toList(),
    );
  }

  /// Linha do pedido: o app usa centavos (int). O back-end manda `subTotal`
  /// (total da linha, em reais) ou, no contrato antigo, `valorTotal` (centavos).
  static int _valorEmCentavos(Map<String, dynamic> item) {
    if (item['valorTotal'] != null) return (item['valorTotal'] as num).toInt();
    final sub = (item['subTotal'] ?? item['valorUnit']) as num?;
    if (sub == null) return 0;
    return (sub.toDouble() * 100).round();
  }

  static List<AdicionaisItem> _parseAdicionais(Map<String, dynamic> item) {
    final lista = (item['adicionais'] ?? item['acompanhamentosid']) as List?;
    if (lista == null) return const [];
    return lista.map((e) {
      if (e is Map) return AdicionaisItem.fromMap(e.cast<String, dynamic>());
      return AdicionaisItem(nomeAdicional: e.toString(), precoAdicional: 0);
    }).toList();
  }
}
