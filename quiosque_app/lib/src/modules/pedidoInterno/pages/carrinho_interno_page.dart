import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/data/api/models/pedido_models.dart';
import 'package:quiosque_app/data/api/pedido_api.dart';
import 'package:quiosque_app/providers/carrinho_interno_provider/carrinho_interno_provider.dart';
import 'package:quiosque_app/providers/pedido_recebido_provider/pedido_recebido_provider.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';
import 'package:quiosque_app/src/shared/utils/formatters.dart';
import 'package:quiosque_app/src/shared/widget/modais.dart';

class CarrinhoInternoPage extends ConsumerStatefulWidget {
  const CarrinhoInternoPage({super.key});

  @override
  ConsumerState<CarrinhoInternoPage> createState() =>
      _CarrinhoInternoPageState();
}

class _CarrinhoInternoPageState extends ConsumerState<CarrinhoInternoPage> {
  bool _isSending = false;
  late final TextEditingController _nomeClienteController;

  @override
  void initState() {
    super.initState();
    // Recupera o nome digitado anteriormente para não perdê-lo ao navegar.
    _nomeClienteController =
        TextEditingController(text: ref.read(nomeClienteInternoProvider));
  }

  @override
  void dispose() {
    _nomeClienteController.dispose();
    super.dispose();
  }

  Widget _campoNomeCliente() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome do cliente:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 4),
          TextField(
            controller: _nomeClienteController,
            textCapitalization: TextCapitalization.words,
            enabled: !_isSending,
            onChanged: (v) =>
                ref.read(nomeClienteInternoProvider.notifier).definir(v),
            decoration: InputDecoration(
              hintText: 'Balcão',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(ItemPedidoRecebido item, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.nome,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Qtde: ${item.qtde}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  formatarPreco(item.subtotal),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              IconButton(
                onPressed: _isSending
                    ? null
                    : () async {
                        final ok = await mostrarModalConfirmacao(
                          context,
                          pergunta: 'Deseja remover o item?',
                        );
                        if (ok == true) {
                          ref
                              .read(carrinhoInternoProvider.notifier)
                              .removerEm(index);
                        }
                      },
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
            ],
          ),

          if (item.ingredientesRemovidos.isNotEmpty ||
              item.complementos.isNotEmpty)
            const Divider(height: 10),

          if (item.ingredientesRemovidos.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(
                  left: 15, right: 20, top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remover:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  ...item.ingredientesRemovidos.map(
                    (ing) => Text(
                      '• $ing',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (item.complementos.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(
                  left: 15, right: 20, top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adicionais:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  ...item.complementos.map(
                    (comp) => Text(
                      '• $comp',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _botaoFazerPedido(List<ItemPedidoRecebido> itens) {
    final total = itens.fold(0, (soma, i) => soma + i.subtotal);
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSending ? null : () => _fazerPedido(itens),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),
        child: _isSending
            ? const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3),
              )
            : Text(
                'Fazer pedido!  ${formatarPreco(total)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _fazerPedido(List<ItemPedidoRecebido> itens) async {
    setState(() => _isSending = true);
    final theme = Theme.of(context);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    void mostrarSnack(String texto, Color cor) {
      messenger.showSnackBar(SnackBar(
        content: Text(
          texto.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: cor,
        duration: const Duration(seconds: 3),
      ));
    }

    try {
      final nome = _nomeClienteController.text.trim();
      final pedido = PedidoInternoRequest(
        nomeCliente: nome.isEmpty ? null : nome,
        itens: itens
            .map((i) => ItemPedidoRequest(
                  itemId: i.itemId ?? 0,
                  quantidade: i.qtde,
                  acompanhamentosId: i.acompanhamentosId,
                  ingredientesId: i.ingredientesId,
                ))
            .toList(),
      );
      await PedidoApi.instance.criarInterno(pedido);

      ref.read(carrinhoInternoProvider.notifier).limpar();
      ref.read(nomeClienteInternoProvider.notifier).definir('');
      // Recarrega a lista de pedidos do quiosque para o novo pedido aparecer.
      ref.invalidate(pedidoRecebidoProvider);

      if (!mounted) return;
      mostrarSnack('Pedido realizado!', theme.colorScheme.primary);
      router.go('/pedidos');
    } on ApiException catch (e) {
      if (mounted) mostrarSnack(e.mensagem, theme.colorScheme.error);
    } catch (_) {
      if (mounted) {
        mostrarSnack('Erro ao realizar pedido!', theme.colorScheme.error);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itens = ref.watch(carrinhoInternoProvider);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Carrinho'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
        children: [
          itens.isEmpty
              ? Center(
                  child: Text(
                    'Seu carrinho está vazio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _campoNomeCliente(),
                        ...itens.asMap().entries.map(
                              (entry) => _itemCard(entry.value, entry.key),
                            ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
          if (_isSending)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black12,
            ),
        ],
        ),
      ),
      bottomNavigationBar: itens.isNotEmpty
          ? SafeArea(
              top: false,
              child: Container(
                color: Colors.transparent,
                child: _botaoFazerPedido(itens),
              ),
            )
          : null,
    );
  }
}