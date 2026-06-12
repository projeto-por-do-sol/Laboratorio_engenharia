import 'package:quiosque_app/data/api/api_client.dart';
import 'package:quiosque_app/data/api/models/cardapio_models.dart';

class ItemApi {
  static final ItemApi instance = ItemApi._();

  ItemApi._();

  final ApiClient _client = ApiClient.instance;

  /// `GET /quiosques/itens/{id}` — detalhe de um item (público).
  Future<ItemView> buscarPorId(int id) async {
    final resp = await _client.get('/quiosques/itens/$id');
    return ItemView.fromJson(resp as Map<String, dynamic>);
  }

  /// `POST /quiosques/me/categorias/{idCategoria}/itens` — cria item (FUNCIONARIO).
  ///
  /// [ingredientes] segue o `IngredienteDTO`: lista de mapas `{id?, nome}`
  /// (use `id` nulo para ingredientes novos). [acompanhamentoIds] são os ids
  /// dos acompanhamentos vinculados.
  Future<ItemView> criar(
    int idCategoria, {
    required String nome,
    String? tipo,
    String? descricao,
    List<Map<String, dynamic>> ingredientes = const [],
    List<int> acompanhamentoIds = const [],
    double? valorBase,
    double? valorPromo,
    int? ordem,
  }) async {
    final resp = await _client.post(
      '/quiosques/me/categorias/$idCategoria/itens',
      body: _corpo(
        nome: nome,
        tipo: tipo,
        descricao: descricao,
        ingredientes: ingredientes,
        acompanhamentoIds: acompanhamentoIds,
        valorBase: valorBase,
        valorPromo: valorPromo,
        ordem: ordem,
      ),
    );
    return ItemView.fromJson(resp as Map<String, dynamic>);
  }

  /// `PUT /quiosques/me/categorias/{idCategoria}/itens/{id}` — atualiza item.
  Future<ItemView> atualizar(
    int idCategoria,
    int id, {
    required String nome,
    String? tipo,
    String? descricao,
    List<Map<String, dynamic>> ingredientes = const [],
    List<int> acompanhamentoIds = const [],
    double? valorBase,
    double? valorPromo,
    int? ordem,
  }) async {
    final resp = await _client.put(
      '/quiosques/me/categorias/$idCategoria/itens/$id',
      body: _corpo(
        id: id,
        nome: nome,
        tipo: tipo,
        descricao: descricao,
        ingredientes: ingredientes,
        acompanhamentoIds: acompanhamentoIds,
        valorBase: valorBase,
        valorPromo: valorPromo,
        ordem: ordem,
      ),
    );
    return ItemView.fromJson(resp as Map<String, dynamic>);
  }

  /// `DELETE /quiosques/me/categorias/{idCategoria}/itens/{id}`.
  Future<void> excluir(int idCategoria, int id) =>
      _client.delete('/quiosques/me/categorias/$idCategoria/itens/$id');

  /// `POST .../itens/{id}/imagem` — envia a imagem do item; retorna o nome.
  Future<String> enviarImagem(int idCategoria, int id, String caminhoArquivo) {
    return _client.uploadArquivo(
      '/quiosques/me/categorias/$idCategoria/itens/$id/imagem',
      campo: 'file',
      caminhoArquivo: caminhoArquivo,
    );
  }

  /// `DELETE .../itens/{id}/imagem` — remove a imagem do item.
  Future<void> removerImagem(int idCategoria, int id) => _client
      .delete('/quiosques/me/categorias/$idCategoria/itens/$id/imagem');

  /// Monta o corpo `ItemCreateRequest`.
  Map<String, dynamic> _corpo({
    int? id,
    required String nome,
    String? tipo,
    String? descricao,
    required List<Map<String, dynamic>> ingredientes,
    required List<int> acompanhamentoIds,
    double? valorBase,
    double? valorPromo,
    int? ordem,
  }) =>
      {
        'id': ?id,
        'nome': nome,
        'tipo': ?tipo,
        'descricao': ?descricao,
        'ingredientes': ingredientes,
        'acompanhamentoIds': acompanhamentoIds,
        'valorBase': ?valorBase,
        'valorPromo': ?valorPromo,
        'ordem': ?ordem,
      };
}
