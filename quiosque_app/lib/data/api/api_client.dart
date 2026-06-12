import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:quiosque_app/data/api/api_config.dart';
import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/data/services/quiosque_service.dart';

/// Cliente HTTP central da API. Responsável por:
/// - montar a URL a partir da [ApiConfig.baseUrl];
/// - injetar o header `Authorization: Bearer <token>` quando há sessão;
/// - serializar/desserializar JSON;
/// - converter erros de rede e respostas != 2xx em [ApiException].
///
/// Os módulos de API (auth, quiosque, pedidos, ...) usam esta classe e não
/// falam com `http` diretamente.
class ApiClient {
  static final ApiClient instance = ApiClient._();

  ApiClient._();

  final http.Client _http = http.Client();
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, String>> _headers({bool comCorpo = false}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (comCorpo) headers['Content-Type'] = 'application/json';
    final token = await QuiosqueService.instance.obterJWT();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse('${ApiConfig.baseUrl}$path');
    if (query == null || query.isEmpty) return base;
    return base.replace(
      queryParameters: query.map((k, v) => MapEntry(k, '$v')),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _enviar(() async =>
        _http.get(_uri(path, query), headers: await _headers()));
  }

  Future<dynamic> post(String path, {Object? body}) {
    return _enviar(() async => _http.post(_uri(path),
        headers: await _headers(comCorpo: true),
        body: body == null ? null : jsonEncode(body)));
  }

  Future<dynamic> put(String path, {Object? body}) {
    return _enviar(() async => _http.put(_uri(path),
        headers: await _headers(comCorpo: true),
        body: body == null ? null : jsonEncode(body)));
  }

  Future<dynamic> patch(String path, {Object? body}) {
    return _enviar(() async => _http.patch(_uri(path),
        headers: await _headers(comCorpo: true),
        body: body == null ? null : jsonEncode(body)));
  }

  Future<dynamic> delete(String path, {Object? body}) {
    return _enviar(() async => _http.delete(_uri(path),
        headers: await _headers(comCorpo: body != null),
        body: body == null ? null : jsonEncode(body)));
  }

  /// Envia um arquivo via `multipart/form-data` (endpoints de imagem).
  /// Os endpoints de upload da API respondem com o nome/URL do arquivo em
  /// texto puro, então retornamos o corpo como string.
  Future<String> uploadArquivo(
    String path, {
    required String campo,
    required String caminhoArquivo,
    String metodo = 'POST',
  }) async {
    try {
      final req = http.MultipartRequest(metodo, _uri(path));
      final token = await QuiosqueService.instance.obterJWT();
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      // Informa o content-type real (o padrão seria application/octet-stream,
      // que o back-end rejeitava com "Arquivo não é uma imagem").
      req.files.add(await http.MultipartFile.fromPath(campo, caminhoArquivo,
          contentType: _tipoDeImagem(caminhoArquivo)));
      final streamed = await req.send().timeout(_timeout);
      final resposta = await http.Response.fromStream(streamed);
      if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
        return utf8.decode(resposta.bodyBytes);
      }
      throw ApiException(resposta.statusCode, _mensagemErro(resposta));
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException.rede();
    } catch (_) {
      throw const ApiException.rede();
    }
  }

  /// Content-type derivado da extensão do arquivo (uploads são sempre
  /// imagens). Devolve null quando a extensão é desconhecida.
  MediaType? _tipoDeImagem(String caminho) {
    final ext = caminho.split('.').last.toLowerCase();
    const subtipos = {
      'jpg': 'jpeg',
      'jpeg': 'jpeg',
      'png': 'png',
      'gif': 'gif',
      'webp': 'webp',
      'bmp': 'bmp',
      'heic': 'heic',
    };
    final subtipo = subtipos[ext];
    return subtipo == null ? null : MediaType('image', subtipo);
  }

  /// Executa a requisição, trata timeout/erros de rede e o status da resposta.
  Future<dynamic> _enviar(Future<http.Response> Function() requisicao) async {
    final http.Response resposta;
    try {
      resposta = await requisicao().timeout(_timeout);
    } on SocketException {
      throw const ApiException.rede();
    } on HttpException {
      throw const ApiException.rede();
    } catch (_) {
      throw const ApiException.rede();
    }

    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      if (resposta.body.isEmpty) return null;
      final texto = utf8.decode(resposta.bodyBytes);
      // Vários endpoints respondem com texto puro (ex.: mensagem de cancelamento,
      // nome de arquivo). Se não for JSON válido, devolvemos a string crua.
      try {
        return jsonDecode(texto);
      } on FormatException {
        return texto;
      }
    }

    throw ApiException(resposta.statusCode, _mensagemErro(resposta));
  }

  /// Extrai uma mensagem amigável do corpo de erro. A API costuma devolver
  /// um JSON com `message`/`error`; caímos para mensagens padrão por status.
  String _mensagemErro(http.Response resposta) {
    try {
      final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (corpo is Map) {
        final msg = corpo['message'] ?? corpo['error'] ?? corpo['detail'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    } catch (_) {
      // corpo não-JSON ou vazio
    }
    switch (resposta.statusCode) {
      case 400:
        return 'Requisição inválida.';
      case 401:
        return 'Sessão expirada. Entre novamente.';
      case 403:
        return 'Você não tem permissão para esta ação.';
      case 404:
        return 'Recurso não encontrado.';
      case 409:
        return 'Conflito com o estado atual.';
      default:
        return 'Erro no servidor (${resposta.statusCode}).';
    }
  }
}
