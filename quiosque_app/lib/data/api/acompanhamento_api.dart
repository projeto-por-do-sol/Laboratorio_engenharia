import 'package:quiosque_app/data/api/api_client.dart';
import 'package:quiosque_app/data/api/models/cardapio_models.dart';

/// Endpoints de acompanhamentos (`/quiosques/me/acompanhamentos`).
/// Ver `ENDPOINTS.md` — seção "Acompanhamentos". Todos exigem FUNCIONARIO.
class AcompanhamentoApi {
  static final AcompanhamentoApi instance = AcompanhamentoApi._();

  AcompanhamentoApi._();

  final ApiClient _client = ApiClient.instance;

  static const _base = '/quiosques/me/acompanhamentos';

  /// `GET /quiosques/me/acompanhamentos` — lista os acompanhamentos do quiosque.
  Future<List<AcompanhamentoView>> listar() async {
    final resp = await _client.get(_base);
    return (resp as List)
        .map((e) => AcompanhamentoView.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /quiosques/me/acompanhamentos` — cria um acompanhamento.
  Future<AcompanhamentoView> criar(
      {required String nome, required double valor}) async {
    final resp = await _client.post(_base, body: {'nome': nome, 'valor': valor});
    return AcompanhamentoView.fromJson(resp as Map<String, dynamic>);
  }

  /// `PUT /quiosques/me/acompanhamentos/{id}` — atualiza um acompanhamento.
  Future<AcompanhamentoView> atualizar(int id,
      {required String nome, required double valor}) async {
    final resp =
        await _client.put('$_base/$id', body: {'nome': nome, 'valor': valor});
    return AcompanhamentoView.fromJson(resp as Map<String, dynamic>);
  }

  /// `DELETE /quiosques/me/acompanhamentos/{id}` — remove um acompanhamento.
  Future<void> excluir(int id) => _client.delete('$_base/$id');
}
