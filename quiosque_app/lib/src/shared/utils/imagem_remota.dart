import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:quiosque_app/data/api/api_config.dart';

/// Indica se [caminho] aponta para uma imagem no servidor (já enviada) e não
/// para um arquivo local recém-escolhido pelo usuário.
bool ehImagemRemota(String? caminho) =>
    caminho != null &&
    (caminho.startsWith('http') || caminho.startsWith('/uploads'));

/// Resolve um caminho de imagem em um [ImageProvider]:
/// - URL absoluta (`http...`) → [NetworkImage];
/// - caminho do servidor (`/uploads/...`) → [NetworkImage] com a base da API;
/// - caminho local (arquivo recém-escolhido) → [FileImage].
///
/// Retorna `null` quando não há imagem, para o chamador exibir um placeholder.
ImageProvider? provedorImagem(String? caminho) {
  if (caminho == null || caminho.isEmpty) return null;
  if (caminho.startsWith('http')) return NetworkImage(caminho);
  if (caminho.startsWith('/uploads')) {
    return NetworkImage('${ApiConfig.baseUrl}$caminho');
  }
  return FileImage(File(caminho));
}
