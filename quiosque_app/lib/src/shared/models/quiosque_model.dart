class QuiosqueModel {
  final String id;
  final String nomeQuiosque;
  final String email;
  final String telefone;
  final String? fotoPath;

  const QuiosqueModel({
    required this.id,
    required this.nomeQuiosque,
    required this.email,
    required this.telefone,
    this.fotoPath,
  });

  QuiosqueModel copyWith({
    String? id,
    String? nomeQuiosque,
    String? email,
    String? telefone,
    String? fotoPath,
    bool clearFoto = false,
  }) {
    return QuiosqueModel(
      id: id ?? this.id,
      nomeQuiosque: nomeQuiosque ?? this.nomeQuiosque,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      fotoPath: clearFoto ? null : (fotoPath ?? this.fotoPath),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeQuiosque': nomeQuiosque,
      'email': email,
      'telefone': telefone,
      'fotoPath': fotoPath,
    };
  }

  factory QuiosqueModel.fromMap(Map<String, dynamic> map) {
    return QuiosqueModel(
      id: map['id'] as String,
      nomeQuiosque: map['nomeQuiosque'] as String,
      email: map['email'] as String,
      telefone: map['telefone'] as String,
      fotoPath: map['fotoPath'] as String?,
    );
  }
}
