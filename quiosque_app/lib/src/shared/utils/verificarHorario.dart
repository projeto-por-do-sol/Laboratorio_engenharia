/// Verifica se a string é um horário válido no formato HH:MM (24h).
/// Ex.: "08:30" é válido, "25:00" e "8h" não são.
bool horarioValido(String horaString) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(horaString.trim());
  if (match == null) return false;
  final hora = int.parse(match.group(1)!);
  final minuto = int.parse(match.group(2)!);
  return hora >= 0 && hora <= 23 && minuto >= 0 && minuto <= 59;
}

DateTime extrairHora(String horaString, DateTime agora) {
  final partes = horaString.split(':');
  final hora = int.parse(partes[0]);
  final minuto = int.parse(partes[1]);

  return DateTime(agora.year, agora.month, agora.day, hora, minuto);
}

bool verificarQuiosqueAberto(String horaAbertura, String horaFechamento) {
  final agora = DateTime.now();

  try {
    final abertura = extrairHora(horaAbertura, agora);
    var fechamento = extrairHora(horaFechamento, agora);

    // Tratamento caso o quiosque feche de madrugada
    if (fechamento.isBefore(abertura)) {
      fechamento = fechamento.add(const Duration(days: 1));
    }

    return (agora.isAfter(abertura) || agora.isAtSameMomentAs(abertura)) &&
        (agora.isBefore(fechamento));

  } catch (e) {
    print("Erro ao formatar horas de funcionamento: $e");
    return false;
  }
}

List<dynamic> verificarCancelamentoPedidoHorario(String horarioPedidoIso) {
  try {
    // Transforma a String ISO 8601 do banco diretamente em DateTime
    final pedido = DateTime.parse(horarioPedidoIso);
    final agora = DateTime.now();

    // Calcula a diferença exata entre os dois momentos
    final diferenca = agora.difference(pedido);

    // Retorna true se passou de 30 minutos e os minutos restantes
    return [diferenca.inMinutes >= 30, 30 - diferenca.inMinutes];

  } catch (e) {
    print("Erro ao processar data do pedido: $e");
    return [false, 0];
  }
}