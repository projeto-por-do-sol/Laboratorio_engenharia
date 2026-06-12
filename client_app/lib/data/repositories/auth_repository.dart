import 'dart:io';

import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/src/shared/models/cliente_model.dart';

/// Acesso remoto à autenticação e ao perfil do cliente (`/auth/*` e `/me`).
///
/// Alinhado ao contrato real do back-end Spring (DTOs):
///   - login:    `{ email, password }` -> `{ token }`
///   - register: `{ nome, email, password, cpf, role, telefone }`
///   - /me:      `{ id, nome, email, telefone, dataCadastro, imagem, role }`
class AuthRepository {
  static final AuthRepository instance = AuthRepository._init();

  final ApiClient _api = ApiClient.instance;

  AuthRepository._init();

  /// `POST /auth/login` — autentica por e-mail/senha. Retorna só o token
  /// (os dados do cliente vêm depois em `GET /me`).
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final resp = await _api.post(
      '/auth/login',
      autenticar: false,
      body: {'email': email, 'password': password},
    );
    return (resp as Map)['token'].toString();
  }

  /// `POST /auth/register` — cria a conta (role `CLIENTE`). NÃO retorna token;
  /// o login é feito em seguida para autenticar.
  Future<ClienteModel> registrar({
    required String nome,
    required String email,
    required String password,
    required String cpf,
    required String telefone,
  }) async {
    final resp = await _api.post(
      '/auth/register',
      autenticar: false,
      body: {
        'nome': nome,
        'email': email,
        'password': password,
        'cpf': cpf,
        'role': 'CLIENTE',
        'telefone': telefone,
      },
    );
    return ClienteModel.fromMap(_clienteJson(resp as Map<String, dynamic>));
  }

  /// `GET /me` — dados do cliente logado.
  Future<ClienteModel> buscarPerfil() async {
    final resp = await _api.get('/me');
    return ClienteModel.fromMap(_clienteJson(resp as Map<String, dynamic>));
  }

  /// `PUT /me` — atualiza o perfil (DTO `UpdateMeDTO`: nome/email/telefone).
  Future<ClienteModel> atualizarPerfil(ClienteModel cliente) async {
    final resp = await _api.put(
      '/me',
      body: {
        'nome': cliente.nomeCompleto,
        'email': cliente.email,
        'telefone': cliente.telefone,
      },
    );
    if (resp is Map<String, dynamic>) {
      return ClienteModel.fromMap(_clienteJson(resp)).copyWith(id: cliente.id);
    }
    return cliente;
  }

  /// `DELETE /me` — exclui a conta do cliente logado.
  Future<void> deletarConta() => _api.delete('/me');

  /// `POST /me/imagem` — envia (multipart, parte `file`) a foto de perfil.
  Future<String?> enviarImagem(File arquivo) async {
    final resp = await _api.enviarArquivo('/me/imagem', arquivo, campo: 'file');
    return resp?.toString();
  }

  /// `DELETE /me/imagem` — remove a foto de perfil.
  Future<void> removerImagem() => _api.delete('/me/imagem');

  /// Normaliza o JSON do usuário do back-end (`nome`/`imagem`) para o
  /// [ClienteModel] do app (`nomeCompleto`/`fotoPath`). O `id` local (sqflite)
  /// não vem do back-end.
  Map<String, dynamic> _clienteJson(Map<String, dynamic> json) {
    return {
      'nomeCompleto': json['nomeCompleto'] ?? json['nome'] ?? '',
      'email': json['email'] ?? '',
      'telefone': json['telefone'] ?? '',
      'fotoPath': json['fotoPath'] ?? json['imagem'] ?? json['url'],
    };
  }
}
