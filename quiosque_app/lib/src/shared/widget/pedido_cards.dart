import 'package:flutter/material.dart';

import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';
import 'package:quiosque_app/src/shared/utils/pedido_status.dart';

/// Card com os dados do cliente: nome, horário e status do pedido.
class PedidoClienteCard extends StatelessWidget {
  final PedidoRecebido pedido;
  const PedidoClienteCard({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(pedido.nomeCliente,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              Text(rotuloStatus(pedido),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.outline)),
            ],
          ),
          const SizedBox(height: 4),
          Text(horaFormatada(pedido),
              style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.outline.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

/// Card com a lista de itens do pedido (com ingredientes removidos e adicionais).
class PedidoItensCard extends StatelessWidget {
  final PedidoRecebido pedido;
  const PedidoItensCard({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in pedido.itens)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.nome,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      Text('qtde: ${item.qtde}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (item.ingredientesRemovidos.isNotEmpty)
                    _listaDetalhe(theme, 'Remover:', item.ingredientesRemovidos),
                  if (item.complementos.isNotEmpty)
                    _listaDetalhe(theme, 'Complementos:', item.complementos),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _cardContainer({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

// Lista de detalhes (ingredientes removidos / complementos) em coluna com
// marcadores, no mesmo formato da página do carrinho.
Widget _listaDetalhe(ThemeData theme, String titulo, List<String> itens) {
  final cor = theme.colorScheme.outline.withValues(alpha: 0.8);
  return Padding(
    padding: const EdgeInsets.only(left: 12, top: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cor)),
        ...itens.map((e) => Text('• $e',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: cor))),
      ],
    ),
  );
}