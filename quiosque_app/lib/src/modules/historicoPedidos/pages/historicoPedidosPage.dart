import 'package:quiosque_app/providers/historico_provider/historico_provider.dart';
import 'package:quiosque_app/src/shared/models/item_carrinho.dart';
import 'package:quiosque_app/src/shared/models/pedidos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HistoricoPedidos extends ConsumerWidget {
  const HistoricoPedidos({super.key});

  double calcularValorTotalPedido(List<ItemCarrinho> item){
    return item.fold(0, (previousValue, element) => previousValue + element.valorTotal) / 100;
  }

  Widget pedidosResumo(BuildContext context, PedidosModel pedido, String dataPedido) {
    final List<ItemCarrinho> item = pedido.itens;
    final QuiosqueCarrinho quiosque = pedido.quiosque;
    final String statusPedido = pedido.status;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      // Ao tocar, abre os detalhes do pedido (cliente, horários e itens).
      onTap: () => context.push('/historicoDetalhe', extra: pedido),
      child: Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),

      decoration: BoxDecoration(
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
        children: [

          Row(
            children: [

              Expanded(
                  child: Text(quiosque.nomeQuiosque,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.w700,
                         color: Theme.of(context).colorScheme.outline
                      )
                  ),
              ),

              Text(dataPedido,
                  style:
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.outline
                  )
              ),

            ],
          ),

          SizedBox(height: 10,),

          ...item.map((elemento) =>
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            elemento.nomeItem,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            'Qtde: ${elemento.qtdeItem}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            'R\$ ${(elemento.valorTotal / 100).toStringAsFixed(2).replaceAll('.', ',')}',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (elemento.ingredientes.isNotEmpty)
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
                            ...elemento.ingredientes.map((ingrediente) =>
                                Text('• $ingrediente', style:
                                TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.outline,
                                )
                                ),
                            )],
                        ),
                      ),

                    if (elemento.adicionais.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(left: 15, top: 5, bottom: 10),
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
                            ...elemento.adicionais.map((adicional) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('• ${adicional.nomeAdicional}', style:
                                TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.outline,
                                )
                                ),

                                Text('R\$ ${(adicional.precoAdicional / 100).toStringAsFixed(2).replaceAll('.', ',')}', style:
                                TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.outline,
                                )
                                )
                              ],
                            )
                            )],
                        ),
                      ),

                  ],
                ),
              ),
          ),

          SizedBox(height: 10,),

            // Valor total do pedido...
            Text(
              'Valor: R\$${calcularValorTotalPedido(item).toStringAsFixed(2).replaceAll('.', ',')}',
                style:
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.outline
                  )
            ),

            const SizedBox(height: 4,),

            // ...e o status logo abaixo.
            Text(statusPedido,
                style:
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary
                  )
            ),

        ],
      )
    )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidos = ref.watch(historicoProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Histórico de pedidos"),
        centerTitle: true,
      ),

      body: pedidos.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (erro, stackTrace) => Center(child: Text("Erro ao carregar pedidos: $erro",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.outline))
        ),

        data: (listaDePedidos) {
          if (listaDePedidos.isEmpty) {
            return Center(child: Text("Nenhum pedido encontrado.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.outline),));
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ...listaDePedidos.map((pedido) =>
                        pedidosResumo(
                            context,
                            pedido,
                            DateFormat('dd/MM/yyyy').format(DateTime.parse(pedido.horaPedido)),
                        ),
                    ),

                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
