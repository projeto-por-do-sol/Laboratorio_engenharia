import 'package:quiosque_app/data/api/api_client.dart';
import 'package:quiosque_app/data/api/models/funcionario_models.dart';

class FuncionarioApi {
  static final FuncionarioApi instance = FuncionarioApi._();

  FuncionarioApi._();

  final ApiClient _client = ApiClient.instance;

  static const _base = '/quiosques/me/funcionarios';

  /// `GET /quiosques/me/funcionarios` — lista os funcionários do quiosque.
  Future<List<FuncionarioView>> listar() async {
    final resp = await _client.get(_base);
    return (resp as List)
        .map((e) => FuncionarioView.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /quiosques/me/funcionarios/{id}` — detalhe de um funcionário.
  Future<FuncionarioView> buscar(String id) async {
    final resp = await _client.get('$_base/$id');
    return FuncionarioView.fromJson(resp as Map<String, dynamic>);
  }

  /// `POST /quiosques/me/funcionarios` — cadastra um funcionário (corpo
  /// `RegisterDTO`). Retorna a senha provisória gerada.
  Future<FuncionarioCriado> criar({
    required String nome,
    required String email,
    required String senha,
    required String role,
    required String telefone,
  }) async {
    final resp = await _client.post(_base, body: {
      'nome': nome,
      'email': email,
      'password': senha,
      'role': role,
      'telefone': telefone,
    });
    return FuncionarioCriado.fromJson(resp as Map<String, dynamic>);
  }

  /// `PUT /quiosques/me/funcionarios/{id}` — atualiza um funcionário.
  Future<FuncionarioView> atualizar(
    String id, {
    required String nome,
    required String email,
    required String senha,
    required String role,
    required String telefone,
  }) async {
    final resp = await _client.put('$_base/$id', body: {
      'nome': nome,
      'email': email,
      'password': senha,
      'role': role,
      'telefone': telefone,
    });
    return FuncionarioView.fromJson(resp as Map<String, dynamic>);
  }

  /// `POST /quiosques/me/funcionarios/{id}/reset-password` — gera nova senha.
  Future<String> resetarSenha(String id) async {
    final resp = await _client.post('$_base/$id/reset-password');
    return resp is String ? resp : '$resp';
  }

  /// `DELETE /quiosques/me/funcionarios/{id}` — remove um funcionário.
  Future<void> excluir(String id) => _client.delete('$_base/$id');

  /// `POST /quiosques/me/funcionarios/{id}/imagem` — envia a imagem.
  Future<String> enviarImagem(String id, String caminhoArquivo) {
    return _client.uploadArquivo('$_base/$id/imagem',
        campo: 'file', caminhoArquivo: caminhoArquivo);
  }

  /// `DELETE /quiosques/me/funcionarios/{id}/imagem` — remove a imagem.
  Future<void> removerImagem(String id) => _client.delete('$_base/$id/imagem');
}
