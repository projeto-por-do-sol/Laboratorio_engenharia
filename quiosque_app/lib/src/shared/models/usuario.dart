import 'package:quiosque_app/src/shared/models/funcionario.dart';

/// Usuário autenticado, espelhando o `UsuarioResponseDTO` da API
/// (`GET /me`, `PUT /me`, `POST /auth/register`).
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final DateTime? dataCadastro;

  /// Nome do arquivo/URL da imagem de perfil retornado pela API (pode ser nulo).
  final String? imagem;

  /// Papel cru vindo da API: `proprietario`, `gerente`, `funcionario`, `cliente`.
  final String role;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
    this.telefone,
    this.dataCadastro,
    this.imagem,
  });

  /// Converte o papel da API no [Cargo] usado pela interface.
  Cargo get cargo {
    switch (role.toLowerCase()) {
      case 'proprietario':
        return Cargo.dono;
      case 'gerente':
        return Cargo.gerente;
      default:
        return Cargo.funcionario;
    }
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    DateTime? parseData(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

    return Usuario(
      id: '${json['id']}',
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telefone: json['telefone'] as String?,
      dataCadastro: parseData(json['dataCadastro']),
      imagem: json['imagem'] as String?,
      role: json['role'] as String? ?? 'funcionario',
    );
  }
}
