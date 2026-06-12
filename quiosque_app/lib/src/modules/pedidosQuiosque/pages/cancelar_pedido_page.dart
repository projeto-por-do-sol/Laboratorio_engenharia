import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/providers/pedido_recebido_provider/pedido_recebido_provider.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';
import 'package:quiosque_app/src/shared/utils/formatters.dart';
import 'package:quiosque_app/src/shared/widget/pedido_cards.dart';

class CancelarPedidoPage extends ConsumerStatefulWidget {
  final PedidoRecebido pedido;
  const CancelarPedidoPage({super.key, required this.pedido});

  @override
  ConsumerState<CancelarPedidoPage> createState() => _CancelarPedidoPageState();
}

class _CancelarPedidoPageState extends ConsumerState<CancelarPedidoPage> {
  final _motivoController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pedido = widget.pedido;

    return Scaffold(
      appBar: AppBar(
        title: Text("Voltar"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PedidoClienteCard(pedido: pedido),
              const SizedBox(height: 16),
              PedidoItensCard(pedido: pedido),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total: ${formatarPreco(pedido.total)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              const Text('Motivo:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: _motivoController,
                maxLines: 8,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outline, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: theme.colorScheme.primary, width: 3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0392B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    // O motivo do cancelamento é opcional.
                    await ref
                        .read(pedidoRecebidoProvider.notifier)
                        .cancelar(pedido.id,
                            motivo: _motivoController.text.trim());
                    if (context.mounted) {
                      context.go('/pedidos');
                    }
                  },
                  child: const Text('CANCELAR',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
