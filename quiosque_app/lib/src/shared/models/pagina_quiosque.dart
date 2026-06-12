import 'package:quiosque_app/src/shared/models/secao.dart';

class PaginaQuiosque {
  final String nome;
  final String? horarioAbre;
  final String? horarioFecha;
  final String? raio; // em metros
  final String? capaPath;
  final String? logoPath;
  final double avaliacao;
  final int qtdeAvaliacoes;
  final List<Secao> secoes;
  // Dias da semana em que o quiosque abre (índice 0 = Domingo ... 6 = Sábado).
  final List<bool> diasFuncionamento;
  // Endereço/coordenadas (para reexibir/editar a localização).
  final String? cep;
  final String? uf;
  final String? cidade;
  final double? latitude;
  final double? longitude;

  const PaginaQuiosque({
    this.nome = 'Nome Quiosque',
    this.horarioAbre,
    this.horarioFecha,
    this.raio,
    this.capaPath,
    this.logoPath,
    this.avaliacao = 0,
    this.qtdeAvaliacoes = 0,
    this.secoes = const [],
    this.diasFuncionamento = const [false, false, false, false, false, false, false],
    this.cep,
    this.uf,
    this.cidade,
    this.latitude,
    this.longitude,
  });

  bool get temHorario => horarioAbre != null && horarioFecha != null;

  bool get temDias => diasFuncionamento.any((d) => d);

  /// Lista abreviada dos dias abertos, ex.: "Seg, Ter, Qua".
  String get diasResumo {
    const nomes = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final abertos = <String>[];
    for (var i = 0; i < diasFuncionamento.length && i < nomes.length; i++) {
      if (diasFuncionamento[i]) abertos.add(nomes[i]);
    }
    return abertos.join(', ');
  }

  PaginaQuiosque copyWith({
    String? nome,
    String? horarioAbre,
    String? horarioFecha,
    String? raio,
    String? capaPath,
    bool clearCapa = false,
    String? logoPath,
    bool clearLogo = false,
    double? avaliacao,
    int? qtdeAvaliacoes,
    List<Secao>? secoes,
    List<bool>? diasFuncionamento,
    String? cep,
    String? uf,
    String? cidade,
    double? latitude,
    double? longitude,
  }) {
    return PaginaQuiosque(
      nome: nome ?? this.nome,
      horarioAbre: horarioAbre ?? this.horarioAbre,
      horarioFecha: horarioFecha ?? this.horarioFecha,
      raio: raio ?? this.raio,
      capaPath: clearCapa ? null : (capaPath ?? this.capaPath),
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      avaliacao: avaliacao ?? this.avaliacao,
      qtdeAvaliacoes: qtdeAvaliacoes ?? this.qtdeAvaliacoes,
      secoes: secoes ?? this.secoes,
      diasFuncionamento: diasFuncionamento ?? this.diasFuncionamento,
      cep: cep ?? this.cep,
      uf: uf ?? this.uf,
      cidade: cidade ?? this.cidade,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
