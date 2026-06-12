import 'package:client_app/providers/pedido_provider/pedido_provider.dart';
import 'package:client_app/src/shared/models/item_carrinho.dart';
import 'package:client_app/src/shared/models/pedidos_model.dart';
import 'package:client_app/src/shared/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AvaliarPedidos extends ConsumerStatefulWidget {
  final PedidosModel pedido;

  const AvaliarPedidos({super.key, required this.pedido});

  @override
  ConsumerState<AvaliarPedidos> createState() => _AvaliarPedidosState();
}

class _AvaliarPedidosState extends ConsumerState<AvaliarPedidos> {
  int _nota = 0;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    // Pré-carrega a nota já dada (quando o pedido voltou como AVALIADO).
    _nota = widget.pedido.nota ?? 0;
  }

  PedidosModel get _pedido => widget.pedido;

  bool get _cancelado => _pedido.cancelado;

  bool get _mostrarMotivo =>
      _pedido.motivoCancelamento?.trim().isNotEmpty ?? false;

  // Só é possível avaliar pedidos que foram finalizados (e ainda não avaliados).
  bool get _podeAvaliar => _pedido.podeAvaliar;

  // Pedido já avaliado: mostra a nota dada, em modo somente leitura.
  bool get _jaAvaliado => _pedido.jaAvaliado;

  Future<void> _avaliar() async {
    if (_enviando) return;
    final colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    void mostrar(String msg, Color cor) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          backgroundColor: cor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    if (_nota == 0) {
      mostrar('Selecione ao menos uma estrela', colorScheme.tertiary);
      return;
    }

    setState(() => _enviando = true);
    try {
      await ref
          .read(pedidoProvider.notifier)
          .avaliarPedido(_pedido.idPedido, _nota);
      // Sucesso: volta para a página de histórico (que já é recarregada com o
      // pedido agora AVALIADO pelo avaliarPedido -> invalidate do histórico).
      if (mounted) Navigator.pop(context);
      return;
    } catch (_) {
      mostrar('Erro ao enviar avaliação. Tente novamente.', colorScheme.error);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voltar")
      ),
      
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    //Card do pedido
                    _CardPedido(
                      quiosque: _pedido.quiosque.nomeQuiosque,
                      data: DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(_pedido.horaPedido)),
                      itens: _pedido.itens,
                      status: _pedido.status,
                      cancelado: _cancelado,
                    ),

                    const SizedBox(height: 14),

                    //Avaliação: pedidos finalizados (avaliar) ou já avaliados
                    //(somente leitura, mostrando a nota dada).
                    if (_podeAvaliar || _jaAvaliado) ...[
                      //Banner avaliação
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          // border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _nota > 0
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: _nota > 0
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.outline,
                              size: 28,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _jaAvaliado
                                  ? 'SUA AVALIAÇÃO'
                                  : 'AVALIE SEU PEDIDO',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.outline,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      //Estrelas (interativas só quando ainda pode avaliar)
                      _estrelasAvaliacao(
                        context,
                        nota: _nota,
                        readOnly: _jaAvaliado,
                        onNota: (r) => setState(() => _nota = r),
                      ),

                      const SizedBox(height: 30),
                    ],

                    //Motivo cancelamento
                    if (_mostrarMotivo)
                      _motivoCard(context, motivo: _pedido.motivoCancelamento!),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            //Botão Avaliar (somente pedidos finalizados)
            if (_podeAvaliar)
              CustomButton(
                label: 'Avaliar',
                onPressed: _avaliar,
              ),

              SizedBox(height: 20,)

          ],
        ),
      ),
    );
  }
}

class _CardPedido extends StatelessWidget {
  final String quiosque;
  final String data;
  final List<ItemCarrinho> itens;
  final String status;
  final bool cancelado;

  const _CardPedido({
    required this.quiosque,
    required this.data,
    required this.itens,
    required this.status,
    required this.cancelado,
  });

  double get _valorTotal =>
      itens.fold<int>(0, (soma, item) => soma + item.valorTotal) / 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        // border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Text(quiosque,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.outline)),
                const Spacer(),
                Text(data,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          ),

          Divider(height: 1, color: Theme.of(context).colorScheme.outline),

          // Itens
          ...itens.map(
            (item) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.nomeItem,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.outline)),
                      ),
                      Text(
                        'R\$ ${(item.valorTotal / 100).toStringAsFixed(2).replaceAll('.', ',')}',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    ],
                  ),

                  // Ingredientes removidos
                  if (item.ingredientes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Remover:',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.outline)),
                          ...item.ingredientes.map(
                            (ing) => Text('• ${ing.nome}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.outline)),
                          ),
                        ],
                      ),
                    ),

                  // Complementos (adicionais)
                  if (item.adicionais.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adicionais:',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.outline)),
                          ...item.adicionais.map(
                            (ad) => Text('• ${ad.nomeAdicional}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.outline)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Preço total do pedido
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Valor: R\$ ${_valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),

          // Status
          Padding(
            padding: const EdgeInsets.only(bottom: 14, top: 10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: cancelado
                    ? Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.4)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: cancelado
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _estrelasAvaliacao(
  BuildContext context, {
  required int nota,
  required void Function(int) onNota,
  bool readOnly = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (i) {

      final filled = i < nota;
      return GestureDetector(
        onTap: readOnly ? null : () => onNota(i + 1),
        child: AnimatedScale(
          scale: filled ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: 54,
              color: filled ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }),
  );
}

Widget _motivoCard(BuildContext context, {required String motivo}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.onSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Motivo cancelamento:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.outline,
                ),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            motivo,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.outline,
              height: 1.55,
            ),
          ),
        ],
      ),
  );
}