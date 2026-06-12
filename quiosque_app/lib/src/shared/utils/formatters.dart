import 'package:flutter/services.dart';

String formatarPreco(int centavos) {
  final valor = (centavos / 100).toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $valor';
}

/// Formata um valor em centavos como dinheiro, sem o símbolo "R$".
/// Ex.: 590 -> "5,90"; 123456 -> "1.234,56".
String formatarCentavosSemSimbolo(int centavos) {
  final reais = centavos ~/ 100;
  final cents = (centavos % 100).toString().padLeft(2, '0');
  // Separador de milhar nos reais.
  final reaisStr = reais.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
  return '$reaisStr,$cents';
}

/// Converte um texto de preço para centavos. Considera apenas os dígitos do
/// texto, tratando-os como centavos (ex.: "1.234,56" -> 123456).
int parsePrecoParaCentavos(String texto) {
  final digitos = texto.replaceAll(RegExp(r'\D'), '');
  if (digitos.isEmpty) return 0;
  return int.parse(digitos);
}

/// Máscara de dinheiro que preenche os centavos primeiro: cada dígito digitado
/// desloca o valor para a esquerda (5 -> 0,05; 59 -> 0,59; 590 -> 5,90).
class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) {
      return const TextEditingValue(text: '');
    }
    // Evita números absurdamente grandes (até ~999 milhões).
    if (digitos.length > 11) digitos = digitos.substring(0, 11);
    final texto = formatarCentavosSemSimbolo(int.parse(digitos));
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
