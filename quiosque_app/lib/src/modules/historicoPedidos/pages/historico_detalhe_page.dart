import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:quiosque_app/src/shared/models/item_carrinho.dart';
import 'package:quiosque_app/src/shared/models/pedidos_model.dart';

/// Detalhes de um pedido do histórico: cliente, horários e itens.
class HistoricoDetalhePage extends StatelessWidget {
  final PedidosModel pedido;

  const HistoricoDetalhePage({super.key, required this.pedido});

  double get _valorTotal =>
      pedido.itens.fold<int>(0, (acc, e) => acc + e.valorTotal) / 100;

  String _formatarDataHora(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final data = DateTime.tryParse(iso);
    if (data == null) return '—';
    return DateFormat('dd/MM/yyyy • HH:mm').format(data);
  }

  String _moeda(num reais) =>
      'R\$ ${reais.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do pedido'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cartao(
                theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _linhaInfo(theme, Icons.storefront_outlined, 'Quiosque',
                        pedido.quiosque.nomeQuiosque),
                    _linhaInfo(theme, Icons.person_outline, 'Cliente',
                        pedido.nomeCliente.isEmpty ? '—' : pedido.nomeCliente),
                    _linhaInfo(theme, Icons.schedule, 'Hora do pedido',
                        _formatarDataHora(pedido.horaPedido)),
                    _linhaInfo(theme, Icons.check_circle_outline,
                        'Hora de finalização',
                        _formatarDataHora(pedido.horaFinalizacao)),
                    _linhaInfo(theme, Icons.info_outline, 'Status',
                        pedido.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Itens',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...pedido.itens.map((item) => _cartaoItem(theme, item)),
              const SizedBox(height: 16),
              _cartao(
                theme,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: outline)),
                    Text(_moeda(_valorTotal),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartao(ThemeData theme, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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

  Widget _linhaInfo(
      ThemeData theme, IconData icone, String rotulo, String valor) {
    final outline = theme.colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(rotulo,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: outline)),
          ),
          Flexible(
            child: Text(valor,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 15,
                    color: outline.withValues(alpha: 0.85))),
          ),
        ],
      ),
    );
  }

  Widget _cartaoItem(ThemeData theme, ItemCarrinho item) {
    final outline = theme.colorScheme.outline;
    return _cartao(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.nomeItem,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: outline)),
              ),
              Text('Qtde: ${item.qtdeItem}',
                  style: TextStyle(fontSize: 14, color: outline)),
              const SizedBox(width: 12),
              Text(_moeda(item.valorTotal / 100),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: outline)),
            ],
          ),
          if (item.ingredientes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remover:',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: outline)),
                  ...item.ingredientes.map((i) => Text('• $i',
                      style: TextStyle(fontSize: 13, color: outline))),
                ],
              ),
            ),
          if (item.adicionais.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Adicionais:',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: outline)),
                  ...item.adicionais.map((a) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('• ${a.nomeAdicional}',
                              style:
                                  TextStyle(fontSize: 13, color: outline)),
                          Text(_moeda(a.precoAdicional / 100),
                              style:
                                  TextStyle(fontSize: 13, color: outline)),
                        ],
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
