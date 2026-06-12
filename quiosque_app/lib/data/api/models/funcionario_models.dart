/// `FuncionarioResponseDTO` — funcionário de um quiosque
/// (`GET/POST/PUT /quiosques/me/funcionarios`).
///
/// O `id` é um UUID (string). `role` vem em caixa alta da API
/// (`FUNCIONARIO`, `GERENTE`, ...).
class FuncionarioView {
  final String id;
  final String nome;
  final String email;
  final String role;
  final String? telefone;
  final String? imagem;

  /// Senha em texto puro do funcionário (gerada pelo sistema), para exibição
  /// na gestão. Nula quando a conta não tem senha gerada pelo sistema.
  final String? senha;

  const FuncionarioView({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
    this.telefone,
    this.imagem,
    this.senha,
  });

  factory FuncionarioView.fromJson(Map<String, dynamic> j) => FuncionarioView(
        id: '${j['id']}',
        nome: j['nome'] as String? ?? '',
        email: j['email'] as String? ?? '',
        role: '${j['role'] ?? 'FUNCIONARIO'}',
        telefone: j['telefone'] as String?,
        imagem: j['imagem'] as String?,
        senha: j['senha'] as String?,
      );
}

/// `RegisterAdminResponseDTO` — resposta ao cadastrar um funcionário, contendo
/// a senha provisória gerada.
class FuncionarioCriado {
  final String id;
  final String nome;
  final String? login;
  final String? senha;
  final String? role;
  final String? telefone;

  const FuncionarioCriado({
    required this.id,
    required this.nome,
    this.login,
    this.senha,
    this.role,
    this.telefone,
  });

  factory FuncionarioCriado.fromJson(Map<String, dynamic> j) => FuncionarioCriado(
        id: '${j['id']}',
        nome: j['nome'] as String? ?? '',
        login: j['login'] as String?,
        senha: j['senha'] as String?,
        role: '${j['role'] ?? ''}',
        telefone: j['telefone'] as String?,
      );
}
