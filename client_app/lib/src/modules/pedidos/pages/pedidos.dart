import 'dart:async';

import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/providers/pedido_provider/pedido_provider.dart';
import 'package:client_app/src/shared/models/item_carrinho.dart';
import 'package:client_app/src/shared/models/pedidos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PedidosPage extends ConsumerStatefulWidget {
  const PedidosPage({super.key});

  @override
  ConsumerState<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends ConsumerState<PedidosPage> {
  Widget identificadorQuiosque(QuiosqueCarrinho quiosque, String status, String horaPedido, String idPedido, String horaPedidoIso, PedidosModel pedido){
    double heightImagem = 80;
    double widthImagem = 90;

    dynamic imagemBanner(){
      return ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        child: ApiClient.imagemUrl(quiosque.imgBannerQuiosque) != null
            ? Image.network(
          ApiClient.imagemUrl(quiosque.imgBannerQuiosque)!,
          height: heightImagem,
          width: widthImagem,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: heightImagem,
              width: widthImagem,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40,),
            );
          },
        )
            : Container(
          height: heightImagem,
          width: widthImagem,
          color: Colors.grey[300],
          child: const Icon(Icons.image, color: Colors.grey, size: 40,),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 30),
      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        children: [

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                imagemBanner(),

                SizedBox(width: 10,),

                Expanded(
                  child: Text(quiosque.nomeQuiosque.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onTertiary,
                    )
                    ,),
                ),
                IconButton(
                    onPressed: (){
                      if (pedido.podeCancelarAgora) {
                        showBottomModal(context, status, horaPedidoIso, idPedido);
                      } else {
                        showContagemCancelamento(context, pedido);
                      }
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: 30,
                      color: Theme.of(context).colorScheme.onTertiary,
                    )
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(status, style:
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget itensCarrinho(ItemCarrinho item, QuiosqueCarrinho quiosque) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),

      decoration: BoxDecoration(
        // color: Colors.white,
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  item.nomeItem,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Qtde: ${item.qtdeItem}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),

              SizedBox(
                width: 80,
                child: Text(
                  'R\$ ${(item.valorTotal / 100).toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),

            ],
          ),

          if(item.ingredientes.isNotEmpty || item.adicionais.isNotEmpty)
            Divider(
              height: 10,

            ),

          if (item.ingredientes.isNotEmpty)
            Container(
              margin: EdgeInsets.only(left: 15, right: 20, top: 5, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Remover:", style:
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.outline,
                  )
                  ),
                  ...item.ingredientes.map((ingrediente) =>
                      Text('• ${ingrediente.nome}', style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      )
                      ),
                  )],
              ),
            ),

          if (item.adicionais.isNotEmpty)
            Container(
              margin: EdgeInsets.only(left: 15, right: 20, top: 5, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Adicionais:", style:
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.outline,
                  )
                  ),
                  ...item.adicionais.map((adicional) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• ${adicional.nomeAdicional}', style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      )
                      ),

                      // Text('R\$ ${(adicional.precoAdicional / 100).toStringAsFixed(2).replaceAll('.', ',')}', style:
                      // TextStyle(
                      //   fontSize: 14,
                      //   fontWeight: FontWeight.w500,
                      //   color: Theme.of(context).colorScheme.outline,
                      // )
                      // )
                    ],
                  )
                  )],
              ),
            ),

        ],
      ),
    );
  }

  Widget caixaCodigoPedido(String codigoPedido){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      margin: EdgeInsets.only(top: 20, right: 60, left: 60),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        children: [
          Text("Código do pedido:",
            style:
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.outline,
              )
          ),

          Text(codigoPedido,
            style:
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.outline,
                letterSpacing: 8.0,
              )
          ),

        ],
      ),
    );
  }

  void showBottomModal(BuildContext context, String statusPedido, String horaPedido, String idPedido) {
    Widget cancelarPedidoEsperando() {
      return SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 15,
                  child: Icon(Icons.cancel_outlined, size: 26, color: Theme.of(context).colorScheme.outline),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    'deseja cancelar o pedido?'.toUpperCase(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onTertiary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    label: const Text('NÃO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.outline,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    label: const Text('SIM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      // Captura antes do await para não usar context após o gap.
                      final messenger = ScaffoldMessenger.of(context);
                      final notifier = ref.read(pedidoProvider.notifier);
                      Navigator.pop(context);
                      try {
                        await notifier.cancelarPedido(idPedido);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Pedido cancelado.')),
                        );
                      } catch (e) {
                        final msg = e is ApiException
                            ? e.message
                            : 'Não foi possível cancelar o pedido.';
                        messenger.showSnackBar(SnackBar(content: Text(msg)));
                      }
                    },
                  ),
                ),

              ],
            ),
          ],
        ),
      );
    }

    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.surface,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: cancelarPedidoEsperando(),
          ),
        );
      },
    );
  }

  // Pedido em PREPARANDO/EM_ENTREGA ainda dentro da janela de 30 min: mostra
  // quanto tempo falta para o cliente poder cancelar (contagem ao vivo).
  void showContagemCancelamento(BuildContext context, PedidosModel pedido) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.surface,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: _ContagemCancelamentoSheet(pedido: pedido),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = ref.watch(pedidoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pedidoProvider.notifier).recarregar(),
          ),
        ],
      ),

      body: pedidos.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (erro, stackTrace) => Center(child: Text("Erro ao carregar pedidos: $erro",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.outline))
        ),

        data: (listaDePedidos) {
          final pedidosAtivos = listaDePedidos.where((p) => p.ativo).toList();

          if (pedidosAtivos.isEmpty) {
            return Center(child: Text("Nenhum pedido encontrado.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.outline),));
          }

          final codigoAtual = pedidosAtivos.first.codigoPedido;

          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  caixaCodigoPedido(codigoAtual),

                  ...pedidosAtivos.map((pedido) =>
                      Column(
                        children: [
                          identificadorQuiosque(
                              pedido.quiosque,
                              pedido.status,
                              DateFormat('HH:mm').format(DateTime.parse(pedido.horaPedido)),
                              pedido.idPedido,
                              pedido.horaPedido,
                              pedido,
                          ),
                          for (var item in pedido.itens)
                            itensCarrinho(item, pedido.quiosque),
                        ],
                      )
                  ),

                  SizedBox(height: 20,),
                ],
              ),
            ),
          );
        },
      ),

    );
  }
}

/// Conteúdo do modal de contagem regressiva: mostra ao vivo quanto falta para o
/// cliente poder cancelar um pedido em PREPARANDO/EM_ENTREGA. O botão de
/// cancelar só habilita quando a janela de 30 min é atingida.
class _ContagemCancelamentoSheet extends ConsumerStatefulWidget {
  final PedidosModel pedido;
  const _ContagemCancelamentoSheet({required this.pedido});

  @override
  ConsumerState<_ContagemCancelamentoSheet> createState() =>
      _ContagemCancelamentoSheetState();
}

class _ContagemCancelamentoSheetState
    extends ConsumerState<_ContagemCancelamentoSheet> {
  late Duration _restante;
  Timer? _timer;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _restante = widget.pedido.tempoParaCancelar ?? Duration.zero;
    if (_restante > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final novo = widget.pedido.tempoParaCancelar ?? Duration.zero;
        setState(() => _restante = novo);
        if (novo <= Duration.zero) _timer?.cancel();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatar(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seg = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$seg';
  }

  Future<void> _cancelar() async {
    if (_enviando) return;
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(pedidoProvider.notifier);
    setState(() => _enviando = true);
    try {
      await notifier.cancelarPedido(widget.pedido.idPedido);
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Pedido cancelado.')),
      );
    } catch (e) {
      final msg = e is ApiException
          ? e.message
          : 'Não foi possível cancelar o pedido.';
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final liberou = _restante <= Duration.zero;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 40, color: colorScheme.outline),
        const SizedBox(height: 12),
        Text(
          liberou
              ? 'Você já pode cancelar este pedido.'
              : 'Você poderá cancelar este pedido em:',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (!liberou) ...[
          const SizedBox(height: 16),
          Text(
            _formatar(_restante),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O cancelamento fica disponível 30 minutos após o quiosque '
            'começar a preparar o pedido.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colorScheme.outline),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.outline,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: _enviando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined),
            label: const Text(
              'Cancelar pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: (liberou && !_enviando) ? _cancelar : null,
          ),
        ),
      ],
    );
  }
}
