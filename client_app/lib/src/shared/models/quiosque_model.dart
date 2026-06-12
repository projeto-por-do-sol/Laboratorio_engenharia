import 'package:client_app/src/shared/utils/verificarHorario.dart';

class QuiosqueModel {
  final String idQuiosque;
  final String nomeQuiosque;
  final String? imgPerfilQuiosque;
  final String? imgBannerQuiosque;
  final double avaliacaoQuiosque;
  final String distanciaQuiosque;
  final bool disponivelEntrega;
  final int tempoEspera;
  List<String>? categorias = [];
  final String horarioAbre;
  final String horarioFecha;
  final int qtdeAvaliacoes;

  /// "Aberto agora" informado pelo back-end (`/quiosques/nearby`). Quando
  /// ausente, calcula localmente a partir do horário.
  final bool? aberto;

  QuiosqueModel({
    required this.idQuiosque,
    required this.nomeQuiosque,
    this.imgPerfilQuiosque,
    this.imgBannerQuiosque,
    this.avaliacaoQuiosque = 0,
    required this.distanciaQuiosque,
    this.disponivelEntrega = true,
    this.tempoEspera = 0,
    this.categorias,
    this.horarioAbre = "08:00",
    this.horarioFecha = "23:00",
    this.qtdeAvaliacoes = 0,
    this.aberto,
  });

  /// Quiosque aberto agora: usa o flag do back-end quando presente; senão,
  /// calcula pelo horário de funcionamento.
  bool get estaAberto =>
      aberto ?? verificarQuiosqueAberto(horarioAbre, horarioFecha);

  factory QuiosqueModel.fromJson(Map<String, dynamic> json) {
    // Aceita tanto os nomes do app quanto os do back-end (`/quiosques/nearby`:
    // id/nome/distancia/nota/imagem/tempoEstimado/distAtendimento).
    final distAtendimento = json['distAtendimento'] as num?;
    final imagem = json['imgBannerQuiosque'] ?? json['imagem'];
    return QuiosqueModel(
      idQuiosque: (json['idQuiosque'] ?? json['id'])?.toString() ?? '',
      nomeQuiosque: (json['nomeQuiosque'] ?? json['nome'] ?? '').toString(),
      imgPerfilQuiosque: json['imgPerfilQuiosque'] ?? json['imagem'],
      imgBannerQuiosque: imagem,
      avaliacaoQuiosque:
          ((json['avaliacaoQuiosque'] ?? json['nota']) as num?)?.toDouble() ?? 0,
      distanciaQuiosque:
          (json['distanciaQuiosque'] ?? json['distancia'])?.toString() ?? '0',
      disponivelEntrega: json['disponivelEntrega'] ??
          (distAtendimento != null && distAtendimento > 0),
      tempoEspera:
          ((json['tempoEspera'] ?? json['tempoEstimado']) as num?)?.toInt() ?? 0,
      categorias:
          (json['categorias'] as List?)?.map((e) => e.toString()).toList(),
      horarioAbre: json['horarioAbre'] ?? json['openingTime'] ?? '08:00',
      horarioFecha: json['horarioFecha'] ?? json['closingTime'] ?? '23:00',
      qtdeAvaliacoes:
          ((json['qtdeAvaliacoes'] ?? json['qtdAvaliacoes']) as num?)?.toInt() ?? 0,
      aberto: json['aberto'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idQuiosque': idQuiosque,
      'nomeQuiosque': nomeQuiosque,
      'imgPerfilQuiosque': imgPerfilQuiosque,
      'imgBannerQuiosque': imgBannerQuiosque,
      'avaliacaoQuiosque': avaliacaoQuiosque,
      'distanciaQuiosque': distanciaQuiosque,
      'disponivelEntrega': disponivelEntrega,
      'tempoEspera': tempoEspera,
      'categorias': categorias,
      'horarioAbre': horarioAbre,
      'horarioFecha': horarioFecha,
      'qtdeAvaliacoes': qtdeAvaliacoes,
    };
  }
}