import 'package:quiosque_app/data/api/api_client.dart';
import 'package:quiosque_app/data/api/models/cardapio_models.dart';

class CategoriaApi {
  static final CategoriaApi instance = CategoriaApi._();

  CategoriaApi._();

  final ApiClient _client = ApiClient.instance;

  /// `GET /quiosques/{id}/categorias` — categorias de um quiosque (público).
  Future<List<CategoriaView>> doQuiosque(int idQuiosque) async {
    final resp = await _client.get('/quiosques/$idQuiosque/categorias');
    return (resp as List)
        .map((e) => CategoriaView.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /quiosques/me/categorias` — cria categoria (FUNCIONARIO).
  Future<CategoriaView> criar({required String nome, int? ordem}) async {
    final resp = await _client.post('/quiosques/me/categorias',
        body: {'nome': nome, 'ordem': ?ordem});
    return CategoriaView.fromJson(resp as Map<String, dynamic>);
  }

  /// `PUT /quiosques/me/categorias/{id}` — atualiza categoria (FUNCIONARIO).
  Future<CategoriaView> atualizar(int id,
      {required String nome, int? ordem}) async {
    final resp = await _client.put('/quiosques/me/categorias/$id',
        body: {'nome': nome, 'ordem': ?ordem});
    return CategoriaView.fromJson(resp as Map<String, dynamic>);
  }

  /// `DELETE /quiosques/me/categorias/{id}` — remove categoria (FUNCIONARIO).
  Future<void> excluir(int id) => _client.delete('/quiosques/me/categorias/$id');
}
