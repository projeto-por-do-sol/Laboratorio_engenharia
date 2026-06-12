class ClienteModel {
  final int? id;
  final String nomeCompleto;
  final String email;
  final String telefone;
  final String? fotoPath;

  const ClienteModel({
    this.id,
    required this.nomeCompleto,
    required this.email,
    required this.telefone,
    this.fotoPath,
  });

  ClienteModel copyWith({
    int? id,
    String? nomeCompleto,
    String? email,
    String? telefone,
    String? fotoPath,
    bool clearFoto = false,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      fotoPath: clearFoto ? null : (fotoPath ?? this.fotoPath),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'telefone': telefone,
      'fotoPath': fotoPath,
    };
  }

  factory ClienteModel.fromMap(Map<String, dynamic> map) {
    return ClienteModel(
      id: map['id'] as int?,
      nomeCompleto: map['nomeCompleto'] as String,
      email: map['email'] as String,
      telefone: map['telefone'] as String,
      fotoPath: map['fotoPath'] as String?,
    );
  }
}
