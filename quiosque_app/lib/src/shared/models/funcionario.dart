enum Cargo {
  funcionario('Funcionário(a)'),
  gerente('Gerente'),
  dono('Dono(a)');

  const Cargo(this.label);
  final String label;

  /// Cargos que podem ser atribuídos a um funcionário cadastrado
  /// (o cargo "dono" pertence apenas ao titular da conta).
  static const List<Cargo> atribuiveis = [Cargo.funcionario, Cargo.gerente];

  /// Cargos que podem gerenciar/alterar informações do quiosque.
  bool get podeGerenciar => this == Cargo.gerente || this == Cargo.dono;

  /// Valor de `role` esperado pela API (enum UserRole, em caixa alta).
  String get roleApi => switch (this) {
        Cargo.dono => 'PROPRIETARIO',
        Cargo.gerente => 'GERENTE',
        Cargo.funcionario => 'FUNCIONARIO',
      };

  /// Converte o `role` cru da API (`FUNCIONARIO`, `GERENTE`, ...) em [Cargo].
  static Cargo fromRole(String? role) => switch (role?.toUpperCase()) {
        'PROPRIETARIO' => Cargo.dono,
        'GERENTE' => Cargo.gerente,
        _ => Cargo.funcionario,
      };
}

class Funcionario {
  final String id;
  final String nomeCompleto;
  final String email;
  final Cargo cargo;
  final String telefone;
  final String? imagem;
  final String usuario;
  final String senha;

  const Funcionario({
    required this.id,
    required this.nomeCompleto,
    required this.email,
    this.cargo = Cargo.funcionario,
    this.telefone = '',
    this.imagem,
    this.usuario = '',
    this.senha = '',
  });

  Funcionario copyWith({
    String? id,
    String? nomeCompleto,
    String? email,
    Cargo? cargo,
    String? telefone,
    String? imagem,
    String? usuario,
    String? senha,
  }) {
    return Funcionario(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      cargo: cargo ?? this.cargo,
      telefone: telefone ?? this.telefone,
      imagem: imagem ?? this.imagem,
      usuario: usuario ?? this.usuario,
      senha: senha ?? this.senha,
    );
  }
}
