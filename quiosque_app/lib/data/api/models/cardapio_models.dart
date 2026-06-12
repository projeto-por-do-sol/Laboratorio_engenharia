// Modelos de leitura do cardápio, espelhando os DTOs da API:
// `AcompanhamentoViewDTO`, `IngredienteDTO`, `ItemDTO`, `CategoriaViewDTO`.

double? _toDouble(dynamic v) => (v as num?)?.toDouble();

/// `AcompanhamentoViewDTO` — adicional opcional de um item.
class AcompanhamentoView {
  final int id;
  final String nome;
  final double? valor;

  const AcompanhamentoView({required this.id, required this.nome, this.valor});

  factory AcompanhamentoView.fromJson(Map<String, dynamic> j) => AcompanhamentoView(
        id: (j['id'] as num).toInt(),
        nome: j['nome'] as String? ?? '',
        valor: _toDouble(j['valor']),
      );
}

/// `IngredienteDTO` — ingrediente que compõe um item.
class IngredienteView {
  final int id;
  final String nome;

  const IngredienteView({required this.id, required this.nome});

  factory IngredienteView.fromJson(Map<String, dynamic> j) => IngredienteView(
        id: (j['id'] as num).toInt(),
        nome: j['nome'] as String? ?? '',
      );
}

/// `ItemDTO` — item do cardápio.
class ItemView {
  final int id;
  final String nome;
  final String? tipo;
  final String? descricao;
  final List<IngredienteView> ingredientes;
  final List<AcompanhamentoView> acompanhamentos;
  final double? valorBase;
  final double? valorPromo;
  final String? imagem;
  final int? ordem;

  const ItemView({
    required this.id,
    required this.nome,
    this.tipo,
    this.descricao,
    this.ingredientes = const [],
    this.acompanhamentos = const [],
    this.valorBase,
    this.valorPromo,
    this.imagem,
    this.ordem,
  });

  factory ItemView.fromJson(Map<String, dynamic> j) => ItemView(
        id: (j['id'] as num).toInt(),
        nome: j['nome'] as String? ?? '',
        tipo: j['tipo'] as String?,
        descricao: j['descricao'] as String?,
        ingredientes: ((j['ingredientes'] as List?) ?? const [])
            .map((e) => IngredienteView.fromJson(e as Map<String, dynamic>))
            .toList(),
        acompanhamentos: ((j['acompanhamentos'] as List?) ?? const [])
            .map((e) => AcompanhamentoView.fromJson(e as Map<String, dynamic>))
            .toList(),
        valorBase: _toDouble(j['valorBase']),
        valorPromo: _toDouble(j['valorPromo']),
        imagem: j['imagem'] as String?,
        ordem: (j['ordem'] as num?)?.toInt(),
      );
}

/// `CategoriaViewDTO` — categoria do cardápio com seus itens.
class CategoriaView {
  final int id;
  final String nome;
  final int? ordem;
  final List<ItemView> itens;

  const CategoriaView({
    required this.id,
    required this.nome,
    this.ordem,
    this.itens = const [],
  });

  factory CategoriaView.fromJson(Map<String, dynamic> j) => CategoriaView(
        // O DTO usa `id_categoria` como nome do campo.
        id: (j['id_categoria'] ?? j['id'] as num?) == null
            ? 0
            : ((j['id_categoria'] ?? j['id']) as num).toInt(),
        nome: j['nome'] as String? ?? '',
        ordem: (j['ordem'] as num?)?.toInt(),
        itens: ((j['itens'] as List?) ?? const [])
            .map((e) => ItemView.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
