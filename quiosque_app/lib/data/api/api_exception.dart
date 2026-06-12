/// Erro originado de uma chamada à API.
///
/// [statusCode] é 0 quando a falha foi de rede (sem resposta do servidor).
/// [mensagem] já vem pronta para exibir ao usuário.
class ApiException implements Exception {
  final int statusCode;
  final String mensagem;

  const ApiException(this.statusCode, this.mensagem);

  /// Falha de conexão (servidor inacessível, sem internet, timeout).
  const ApiException.rede([
    this.mensagem = 'Não foi possível conectar ao servidor.',
  ]) : statusCode = 0;

  bool get naoAutorizado => statusCode == 401 || statusCode == 403;

  @override
  String toString() => 'ApiException($statusCode): $mensagem';
}
