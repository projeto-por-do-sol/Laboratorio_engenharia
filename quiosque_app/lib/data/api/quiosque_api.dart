import 'package:quiosque_app/data/api/api_client.dart';
import 'package:quiosque_app/data/api/models/quiosque_models.dart';

/// Endpoints de quiosque (`/quiosques`). Ver `ENDPOINTS.md` — seção "Quiosques".
class QuiosqueApi {
  static final QuiosqueApi instance = QuiosqueApi._();

  QuiosqueApi._();

  final ApiClient _client = ApiClient.instance;

  /// `GET /quiosques/nearby` — quiosques próximos a uma coordenada (público).
  Future<List<QuiosqueNearby>> proximos({
    required double latUsuario,
    required double lonUsuario,
    required double raioM,
  }) async {
    final resp = await _client.get('/quiosques/nearby', query: {
      'latUsuario': latUsuario,
      'lonUsuario': lonUsuario,
      'raioM': raioM,
    });
    return (resp as List)
        .map((e) => QuiosqueNearby.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /quiosques/{id}` — visão detalhada de um quiosque (público).
  Future<QuiosqueView> buscarPorId(int id) async {
    final resp = await _client.get('/quiosques/$id');
    return QuiosqueView.fromJson(resp as Map<String, dynamic>);
  }

  /// `GET /quiosques/me` — quiosque do funcionário autenticado.
  Future<QuiosqueView> buscarMeu() async {
    final resp = await _client.get('/quiosques/me');
    return QuiosqueView.fromJson(resp as Map<String, dynamic>);
  }

  /// `POST /quiosques` — cria um quiosque (PROPRIETARIO).
  Future<QuiosqueResumo> criar(Map<String, dynamic> dados) async {
    final resp = await _client.post('/quiosques', body: dados);
    return QuiosqueResumo.fromJson(resp as Map<String, dynamic>);
  }

  /// `PUT /quiosques/me` — atualiza o quiosque (GERENTE).
  ///
  /// [dados] segue o `QuiosqueDTO`: nome, email, cnpj, openingTime, closingTime
  /// (`HH:mm`), distAtendimento, cep, uf, cidade, latitude, longitude.
  Future<QuiosqueResumo> atualizar(Map<String, dynamic> dados) async {
    final resp = await _client.put('/quiosques/me', body: dados);
    return QuiosqueResumo.fromJson(resp as Map<String, dynamic>);
  }

  /// `PATCH /quiosques/me/status` — alterna o status (aberto/fechado) (GERENTE).
  Future<QuiosqueResumo> alternarStatus() async {
    final resp = await _client.patch('/quiosques/me/status');
    return QuiosqueResumo.fromJson(resp as Map<String, dynamic>);
  }

  /// `DELETE /quiosques/me` — exclui o quiosque (PROPRIETARIO).
  Future<void> excluir() => _client.delete('/quiosques/me');

  /// `POST /quiosques/me/imagem` — envia a imagem do quiosque; retorna o nome.
  Future<String> enviarImagem(String caminhoArquivo) {
    return _client.uploadArquivo('/quiosques/me/imagem',
        campo: 'file', caminhoArquivo: caminhoArquivo);
  }

  /// `DELETE /quiosques/me/imagem` — remove a imagem do quiosque.
  Future<void> removerImagem() => _client.delete('/quiosques/me/imagem');
}
