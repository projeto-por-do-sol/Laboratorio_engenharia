import 'package:flutter/material.dart';

/// Seções pré-criadas que o quiosque pode adicionar à sua página.
///
/// Cada seção possui uma cor de categoria fixa, usada para destacar a seção
/// na página do quiosque. Apenas estas seções podem ser adicionadas.
class SecaoPredefinida {
  final String nome;
  final Color cor;

  const SecaoPredefinida(this.nome, this.cor);
}

const List<SecaoPredefinida> secoesPredefinidas = [
  SecaoPredefinida('Lanches', Color(0xFFE67E22)),
  SecaoPredefinida('Porções', Color(0xFFD35400)),
  SecaoPredefinida('Bebidas', Color(0xFF2980B9)),
  SecaoPredefinida('Outros', Color(0xFF7F8C8D)),
  SecaoPredefinida('Petiscos', Color(0xFFC0392B)),
  SecaoPredefinida('Frutos do mar', Color(0xFF16A085)),
  SecaoPredefinida('Sobremesas', Color(0xFFE84393)),
  SecaoPredefinida('Açaí', Color(0xFF6C3483)),
  SecaoPredefinida('Sucos', Color(0xFFF39C12)),
  SecaoPredefinida('Coquetéis', Color(0xFFAF7AC5)),
  SecaoPredefinida('Cervejas', Color(0xFFB7950B)),
  SecaoPredefinida('Grelhados', Color(0xFF8E5A3C)),
  SecaoPredefinida('Saladas', Color(0xFF27AE60)),
  SecaoPredefinida('Caldos', Color(0xFFCB6436)),
  SecaoPredefinida('Sorvetes', Color(0xFF5DADE2)),
];

/// Cor da categoria associada ao nome da seção. Retorna uma cor neutra caso
/// o nome não corresponda a nenhuma seção pré-criada.
Color corSecao(String nome) {
  for (final s in secoesPredefinidas) {
    if (s.nome.toLowerCase() == nome.toLowerCase()) return s.cor;
  }
  return const Color(0xFF7F8C8D);
}
