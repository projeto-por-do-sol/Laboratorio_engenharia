import 'dart:io';

import 'package:client_app/data/repositories/auth_repository.dart';
import 'package:client_app/data/repositories/cliente_repository.dart';
import 'package:client_app/src/shared/models/cliente_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

class ClienteService {
  static final ClienteService instance = ClienteService._init();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ClienteRepository _repository = ClienteRepository.instance;
  final AuthRepository _auth = AuthRepository.instance;

  static const _jwtKey = 'jwt_token';

  ClienteService._init();

  /// Login real (`POST /auth/login`, autentica por e-mail). Salva o JWT,
  /// busca o perfil em `GET /me` e faz cache local.
  Future<ClienteModel> login({
    required String login,
    required String senha,
  }) async {
    final token = await _auth.login(email: login, password: senha);
    await salvarJWT(token);
    final perfil = await _auth.buscarPerfil();
    await salvarCliente(perfil);
    return (await buscarCliente()) ?? perfil;
  }

  /// Cadastro real (`POST /auth/register`, role CLIENTE) seguido de login
  /// automático — o `/auth/register` não devolve token.
  Future<ClienteModel> cadastrar({
    required String nomeCompleto,
    required String email,
    required String telefone,
    required String cpf,
    required String senha,
  }) async {
    await _auth.registrar(
      nome: nomeCompleto,
      email: email,
      password: senha,
      cpf: cpf,
      telefone: telefone,
    );
    return login(login: email, senha: senha);
  }

  /// Busca o perfil no back-end (`GET /me`) e atualiza o cache local.
  /// Em caso de falha de rede, devolve o cache local (modo offline).
  Future<ClienteModel?> carregarPerfil() async {
    try {
      final remoto = await _auth.buscarPerfil();
      await salvarCliente(remoto);
      return await buscarCliente();
    } catch (_) {
      return buscarCliente();
    }
  }

  /// Atualiza o perfil no back-end (`PUT /me`) e no cache local.
  Future<ClienteModel?> atualizarPerfil(ClienteModel cliente) async {
    final atualizado = await _auth.atualizarPerfil(cliente);
    await salvarCliente(atualizado);
    return buscarCliente();
  }

  /// Envia a foto de perfil (`POST /me/imagem`) e atualiza o cache local.
  Future<ClienteModel?> enviarImagemPerfil(File arquivo) async {
    final fotoPath = await _auth.enviarImagem(arquivo);
    final atual = await buscarCliente();
    if (atual != null) {
      await salvarCliente(atual.copyWith(fotoPath: fotoPath));
    }
    return buscarCliente();
  }

  /// Remove a foto de perfil (`DELETE /me/imagem`).
  Future<ClienteModel?> removerImagemPerfil() async {
    await _auth.removerImagem();
    final atual = await buscarCliente();
    if (atual != null) {
      await salvarCliente(atual.copyWith(clearFoto: true));
    }
    return buscarCliente();
  }

  /// Exclui a conta no back-end (`DELETE /me`) e limpa os dados locais.
  Future<void> deletarConta() async {
    try {
      await _auth.deletarConta();
    } finally {
      await deletarDadosCliente();
    }
  }

  Future<void> salvarJWT(String token) async {
    await _secureStorage.write(key: _jwtKey, value: token);
  }

  Future<String?> obterJWT() async {
    return await _secureStorage.read(key: _jwtKey);
  }

  Future<void> deletarJWT() async {
    await _secureStorage.delete(key: _jwtKey);
  }

  Future<bool> estaLogado() async {
    final token = await obterJWT();
    return token != null && token.isNotEmpty;
  }

  Future<ClienteModel?> buscarCliente() => _repository.buscarCliente();

  Future<void> salvarCliente(ClienteModel cliente) async {
    final existente = await _repository.buscarCliente();
    if (existente == null) {
      await _repository.inserirCliente(cliente);
    } else {
      await _repository.atualizarCliente(cliente.copyWith(id: existente.id));
    }
  }

  Future<void> deletarDadosCliente() async {
    await deletarJWT();
    await _repository.deletarCliente();
  }

  Future<Position?> obterLocalizacao() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Se não houver um fix dentro do tempo limite, cai para a última
      // posição conhecida para não travar o carregamento dos quiosques.
      return await Geolocator.getLastKnownPosition();
    }
  }
}
