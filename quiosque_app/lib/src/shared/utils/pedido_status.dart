import 'package:flutter/material.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';

/// Cor do indicador do pedido conforme o tempo decorrido:
/// Verde = recém-criado (até 15 min); Amarelo = após 15 min; Vermelho = após 30 min.
Color corPedido(PedidoRecebido pedido) {
  final minutos = DateTime.now().difference(pedido.horaDateTime).inMinutes;
  if (minutos < 15) return const Color(0xFF4A8C7A);
  if (minutos < 30) return const Color(0xFFE6B800);
  return const Color(0xFFC0392B);
}

String rotuloStatus(PedidoRecebido pedido) {
  switch (pedido.status) {
    case 'aceitar':
      return 'Aceitar?';
    case 'aceito':
      return 'Aceito';
    case 'preparando':
      return 'Preparando';
    case 'entregando':
      return 'Entregando';
    case 'finalizado':
      return 'Finalizado';
    case 'cancelado':
      return 'Cancelado';
    default:
      return pedido.status;
  }
}

String horaFormatada(PedidoRecebido pedido) {
  final h = pedido.horaDateTime;
  return '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';
}
