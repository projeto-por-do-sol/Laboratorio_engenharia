import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Erro lançado quando o back-end responde com status fora da faixa 2xx
/// (ou quando a requisição falha). As telas/serviços podem inspecionar
/// [statusCode] (ex.: 401 = credenciais inválidas, 404 = não encontrado).
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;

  ApiException(this.statusCode, this.message, [this.body]);

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Cliente HTTP central do app.
///
/// - A base URL vem de `--dart-define=API_BASE_URL=...` (default
///   `http://localhost:8080`, conforme `ENDPOINTS.md`). No emulador Android,
///   use `http://10.0.2.2:8080` para alcançar o host.
/// - O JWT do cliente logado (`flutter_secure_storage`, key `jwt_token`) é
///   injetado automaticamente no header `Authorization: Bearer <token>`.
class ApiClient {
  static final ApiClient instance = ApiClient._init();

  ApiClient._init();

  /// URL informada em build via `--dart-define=API_BASE_URL=...` (tem
  /// prioridade). Vazia quando não fornecida.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Base URL efetiva.
  ///
  /// - Se `API_BASE_URL` foi passado no build, usa ele.
  /// - No emulador Android, `localhost` aponta para o próprio emulador, então
  ///   o default é `http://10.0.2.2:8080` (host visto de dentro do emulador).
  /// - Nas demais plataformas, `http://localhost:8080`.
  ///
  /// Em um **dispositivo Android físico**, use o IP da sua máquina na rede:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080`.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  /// Monta a URL absoluta de uma imagem servida pelo back-end a partir do
  /// que vem salvo: uma URL já absoluta (`http...`), um caminho (`/uploads/x`)
  /// ou só o nome do arquivo (`x` → `/uploads/x`). Retorna `null` se vazio.
  static String? imagemUrl(String? caminho) {
    if (caminho == null || caminho.isEmpty) return null;
    if (caminho.startsWith('http://') || caminho.startsWith('https://')) {
      return caminho;
    }
    if (caminho.startsWith('/')) return '$baseUrl$caminho';
    return '$baseUrl/uploads/$caminho';
  }

  static const _jwtKey = 'jwt_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(baseUrl);
    final params = <String, String>{};
    query?.forEach((chave, valor) {
      if (valor != null) params[chave] = valor.toString();
    });
    return base.replace(
      path: '${base.path}$path',
      queryParameters: params.isEmpty ? null : params,
    );
  }

  Future<String?> _token() => _secureStorage.read(key: _jwtKey);

  Future<Map<String, String>> _headers({
    bool comCorpoJson = true,
    bool autenticar = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (comCorpoJson) headers['Content-Type'] = 'application/json';
    if (autenticar) {
      final token = await _token();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Decodifica o corpo e converte respostas de erro em [ApiException].
  dynamic _processar(http.Response res) {
    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = res.body;
      }
    }

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (!ok) {
      String mensagem = 'Falha na requisição (${res.statusCode})';
      if (decoded is Map && decoded['message'] != null) {
        mensagem = decoded['message'].toString();
      } else if (decoded is String && decoded.isNotEmpty) {
        mensagem = decoded;
      }
      throw ApiException(res.statusCode, mensagem, decoded);
    }
    return decoded;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool autenticar = true,
  }) async {
    final res = await http.get(
      _uri(path, query),
      headers: await _headers(comCorpoJson: false, autenticar: autenticar),
    );
    return _processar(res);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    bool autenticar = true,
  }) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(autenticar: autenticar),
      body: body != null ? jsonEncode(body) : null,
    );
    return _processar(res);
  }

  Future<dynamic> put(String path, {Object? body, bool autenticar = true}) async {
    final res = await http.put(
      _uri(path),
      headers: await _headers(autenticar: autenticar),
      body: body != null ? jsonEncode(body) : null,
    );
    return _processar(res);
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    bool autenticar = true,
  }) async {
    final res = await http.patch(
      _uri(path),
      headers: await _headers(autenticar: autenticar),
      body: body != null ? jsonEncode(body) : null,
    );
    return _processar(res);
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    bool autenticar = true,
  }) async {
    final res = await http.delete(
      _uri(path),
      headers: await _headers(autenticar: autenticar),
      body: body != null ? jsonEncode(body) : null,
    );
    return _processar(res);
  }

  /// Envia um arquivo via `multipart/form-data` (upload de imagem).
  ///
  /// Define o `Content-Type` da parte como `image/<ext>` — o back-end rejeita
  /// uploads sem um content-type de imagem (cairia em `application/octet-stream`).
  Future<dynamic> enviarArquivo(
    String path,
    File arquivo, {
    String campo = 'file',
    String metodo = 'POST',
  }) async {
    final req = http.MultipartRequest(metodo, _uri(path));
    final token = await _token();
    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    req.files.add(await http.MultipartFile.fromPath(
      campo,
      arquivo.path,
      contentType: _tipoImagem(arquivo.path),
    ));
    final res = await http.Response.fromStream(await req.send());
    return _processar(res);
  }

  MediaType _tipoImagem(String caminho) {
    final ext = caminho.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
        return MediaType('image', 'heic');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
