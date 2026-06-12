import 'package:quiosque_app/data/api/api_client.dart';
import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/src/shared/models/usuario.dart';

class AuthApi {
  static final AuthApi instance = AuthApi._();

  AuthApi._();

  final ApiClient _client = ApiClient.instance;

  /// `POST /auth/login` — retorna o token JWT.
  Future<String> login({required String email, required String senha}) async {
    final dynamic resp;
    try {
      resp = await _client.post('/auth/login', body: {
        'email': email,
        'password': senha,
      });
    } on ApiException catch (e) {
      // O back-end responde 401/403 (sem corpo) para credenciais inválidas.
      // Traduzimos para uma mensagem de login clara em vez da genérica de
      // permissão ("Você não tem permissão para esta ação").
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw const ApiException(401, 'E-mail ou senha inválidos.');
      }
      rethrow;
    }
    final token = (resp as Map)['token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('Resposta de login sem token.');
    }
    return token;
  }

  /// `POST /auth/register` — cria um usuário. [role] deve ser um valor do enum
  /// da API (`funcionario`, `cliente`, ...). Requer estar autenticado.
  Future<Usuario> register({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    required String role,
    required String telefone,
  }) async {
    final resp = await _client.post('/auth/register', body: {
      'nome': nome,
      'email': email,
      'password': senha,
      'cpf': cpf,
      'role': role,
      'telefone': telefone,
    });
    return Usuario.fromJson(resp as Map<String, dynamic>);
  }

  /// `GET /me` — dados do usuário autenticado.
  Future<Usuario> me() async {
    final resp = await _client.get('/me');
    return Usuario.fromJson(resp as Map<String, dynamic>);
  }

  /// `PUT /me` — atualização parcial do perfil (campos nulos são ignorados).
  Future<Usuario> atualizarPerfil({
    String? nome,
    String? email,
    String? telefone,
  }) async {
    final resp = await _client.put('/me', body: {
      'nome': ?nome,
      'email': ?email,
      'telefone': ?telefone,
    });
    return Usuario.fromJson(resp as Map<String, dynamic>);
  }

  /// `PATCH /me` — troca de senha.
  Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    await _client.patch('/me', body: {
      'senhaAtual': senhaAtual,
      'novaSenha': novaSenha,
    });
  }

  /// `DELETE /me` — exclui a própria conta.
  Future<void> excluirConta() async {
    await _client.delete('/me');
  }

  /// `POST /me/notification-token` — registra o token de push (FCM).
  Future<void> registrarTokenNotificacao(String token) async {
    await _client.post('/me/notification-token', body: {'token': token});
  }
}
