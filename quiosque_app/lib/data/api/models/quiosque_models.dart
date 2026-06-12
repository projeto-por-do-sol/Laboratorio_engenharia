import 'package:quiosque_app/data/api/models/cardapio_models.dart';

/// Modelos de quiosque, espelhando `QuiosqueViewDTO`, `QuiosqueCreateDTO`
/// e `QuiosqueNearByResponseDTO`.

double? _toDouble(dynamic v) => (v as num?)?.toDouble();
int? _toInt(dynamic v) => (v as num?)?.toInt();

/// `QuiosqueViewDTO` — visão pública/detalhada de um quiosque (`GET /quiosques/{id}`
/// e `GET /quiosques/me`), incluindo o cardápio (categorias + itens).
class QuiosqueView {
  final String nome;
  final double? nota;
  final int qtdAvaliacoes;
  final int? distancia;
  final int? tempoEstimado;
  final String? openingTime;
  final String? closingTime;
  final List<CategoriaView> categorias;
  final String? imagem;
  final String? cep;
  final String? uf;
  final String? cidade;
  final double? latitude;
  final double? longitude;

  const QuiosqueView({
    required this.nome,
    this.nota,
    this.qtdAvaliacoes = 0,
    this.distancia,
    this.tempoEstimado,
    this.openingTime,
    this.closingTime,
    this.categorias = const [],
    this.imagem,
    this.cep,
    this.uf,
    this.cidade,
    this.latitude,
    this.longitude,
  });

  factory QuiosqueView.fromJson(Map<String, dynamic> j) => QuiosqueView(
        nome: j['nome'] as String? ?? '',
        nota: _toDouble(j['nota']),
        qtdAvaliacoes: _toInt(j['qtdAvaliacoes']) ?? 0,
        distancia: _toInt(j['distancia']),
        tempoEstimado: _toInt(j['tempoEstimado']),
        openingTime: j['openingTime'] as String?,
        closingTime: j['closingTime'] as String?,
        categorias: ((j['categorias'] as List?) ?? const [])
            .map((e) => CategoriaView.fromJson(e as Map<String, dynamic>))
            .toList(),
        imagem: j['imagem'] as String?,
        cep: j['cep'] as String?,
        uf: j['uf'] as String?,
        cidade: j['cidade'] as String?,
        latitude: _toDouble(j['latitude']),
        longitude: _toDouble(j['longitude']),
      );
}

/// `QuiosqueCreateDTO` — resumo retornado ao criar/atualizar o quiosque.
class QuiosqueResumo {
  final int? id;
  final String nome;
  final String? email;
  final String? cep;
  final String? uf;
  final String? cidade;
  final double? latitude;
  final double? longitude;

  /// `StatusConta`: `Ativa`, `Desativada` ou `Bloqueada`.
  final String? status;

  const QuiosqueResumo({
    this.id,
    required this.nome,
    this.email,
    this.cep,
    this.uf,
    this.cidade,
    this.latitude,
    this.longitude,
    this.status,
  });

  factory QuiosqueResumo.fromJson(Map<String, dynamic> j) => QuiosqueResumo(
        id: _toInt(j['id']),
        nome: j['nome'] as String? ?? '',
        email: j['email'] as String?,
        cep: j['cep'] as String?,
        uf: j['uf'] as String?,
        cidade: j['cidade'] as String?,
        latitude: _toDouble(j['latitude']),
        longitude: _toDouble(j['longitude']),
        status: j['status'] as String?,
      );
}

/// `QuiosqueNearByResponseDTO` — item da busca por proximidade (`GET /quiosques/nearby`).
class QuiosqueNearby {
  final int id;
  final String nome;
  final int? distancia;
  final int? distAtendimento;
  final int? tempoEstimado;
  final List<String> categorias;
  final double? nota;
  final String? imagem;
  final String? openingTime;
  final String? closingTime;
  final bool aberto;

  const QuiosqueNearby({
    required this.id,
    required this.nome,
    this.distancia,
    this.distAtendimento,
    this.tempoEstimado,
    this.categorias = const [],
    this.nota,
    this.imagem,
    this.openingTime,
    this.closingTime,
    this.aberto = false,
  });

  factory QuiosqueNearby.fromJson(Map<String, dynamic> j) => QuiosqueNearby(
        id: (j['id'] as num).toInt(),
        nome: j['nome'] as String? ?? '',
        distancia: _toInt(j['distancia']),
        distAtendimento: _toInt(j['distAtendimento']),
        tempoEstimado: _toInt(j['tempoEstimado']),
        categorias: ((j['categorias'] as List?) ?? const [])
            .map((e) => '$e')
            .toList(),
        nota: _toDouble(j['nota']),
        imagem: j['imagem'] as String?,
        openingTime: j['openingTime'] as String?,
        closingTime: j['closingTime'] as String?,
        aberto: j['aberto'] as bool? ?? false,
      );
}
