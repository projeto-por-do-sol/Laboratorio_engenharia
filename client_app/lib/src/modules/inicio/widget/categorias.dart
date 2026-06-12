import 'package:flutter/material.dart';

class CategoriasQuiosques extends StatelessWidget {
  final String categoria;

  final Map<String, List<Color>> coresCategorias = {
    'Lanches':       [Color(0xFFFDE8DA), Color(0xFFC0420A)], // areia + coral escuro
    'Porções':       [Color(0xFFF5C4A8), Color(0xFF7A2200)], // salmão + marrom
    'Bebidas':       [Color(0xFFE8F7FA), Color(0xFF0D7A9E)], // azul gelo + azul mar
    'Outros':         [Color(0xFFFFF3DC), Color(0xFF8B5E00)], // creme + dourado escuro

    'Petiscos':      [Color(0xFFFEF3D0), Color(0xFFE8A82A)], // amarelo claro + âmbar
    'Frutos do mar': [Color(0xFFE0F4EF), Color(0xFF1A6B5A)], // verde água + verde escuro
    'Sobremesas':    [Color(0xFFFDE0F0), Color(0xFFB03A6A)], // rosê + vinho
    'Açaí':          [Color(0xFFF0E6FA), Color(0xFF6A2A90)], // lilás + roxo
    'Sucos':         [Color(0xFFEAF5DC), Color(0xFF4A8A1A)], // verde limão + verde
    'Coquetéis':     [Color(0xFFFDE8DA), Color(0xFFE8612A)], // areia + laranja
    'Cervejas':      [Color(0xFFFFF8DC), Color(0xFF9A7200)], // palha + dourado
    'Grelhados':     [Color(0xFFFAEAE0), Color(0xFF8B3A0A)], // terracota claro + marrom
    'Saladas':       [Color(0xFFE8F5E0), Color(0xFF2A7A2A)], // verde claro + verde
    'Caldos':        [Color(0xFFFFF0E0), Color(0xFFB05A00)], // laranja pastel + laranja
    'Sorvetes':      [Color(0xFFE8F0FF), Color(0xFF2A4AB0)], // azul pastel + azul
  };

  CategoriasQuiosques({
    super.key,
    required this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: coresCategorias[categoria]?[0] ?? Color(0xFFFFF3DC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(categoria, style: TextStyle(color: coresCategorias[categoria]?[1] ?? Color(0xFF8B5E00))),
    );
  }
}
