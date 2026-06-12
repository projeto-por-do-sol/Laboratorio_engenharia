import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/providers/pedido_recebido_provider/pedido_recebido_provider.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';
import 'package:quiosque_app/src/shared/utils/pedido_status.dart';

class PedidosQuiosquePage extends ConsumerStatefulWidget {
  const PedidosQuiosquePage({super.key});

  @override
  ConsumerState<PedidosQuiosquePage> createState() =>
      _PedidosQuiosquePageState();
}

class _PedidosQuiosquePageState extends ConsumerState<PedidosQuiosquePage>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // O push FCM é o caminho principal de atualização: com o app aberto,
    // `onMessage` recarrega a lista na hora (ver pedidoRecebidoProvider).
    WidgetsBinding.instance.addObserver(this);
    // A cor de cada pedido depende do tempo decorrido; recalcula periodicamente.
    // O poll silencioso no mesmo tique é só uma rede de segurança para o caso
    // raro de um push não chegar com o app aberto.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.read(pedidoRecebidoProvider.notifier).atualizarSilencioso();
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ao voltar para o primeiro plano, recarrega: cobre os pushes recebidos
    // enquanto o app estava em background (quando o sistema apenas mostra a
    // notificação na bandeja e `onMessage` não dispara).
    if (state == AppLifecycleState.resumed) {
      ref.read(pedidoRecebidoProvider.notifier).atualizarSilencioso();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pedidosAsync = ref.watch(pedidoRecebidoProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/cardapioInterno'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Espaço-fantasma para manter o título centralizado em relação
                  // ao botão de recarregar à direita.
                  const SizedBox(width: 48),
                  Expanded(
                    child: Text('PEDIDOS',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Recarregar pedidos',
                    color: theme.colorScheme.primary,
                    onPressed: () =>
                        ref.read(pedidoRecebidoProvider.notifier).recarregar(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: pedidosAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _erroView(theme, ref),
                data: (pedidos) {
                  if (pedidos.isEmpty) {
                    return Center(
                        child: Text('Nenhum pedido encontrado.',
                            style:
                                TextStyle(color: theme.colorScheme.outline)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: pedidos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _CardPedido(pedido: pedidos[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _erroView(ThemeData theme, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('Não foi possível carregar os pedidos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.outline)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  ref.read(pedidoRecebidoProvider.notifier).recarregar(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPedido extends ConsumerWidget {
  final PedidoRecebido pedido;
  const _CardPedido({required this.pedido});

  // Executa uma ação do provider (aceitar/rejeitar/trocar status) tratando
  // falhas da API com um aviso, em vez de deixar o erro passar silencioso.
  Future<void> _acao(
      BuildContext context, Future<void> Function() acao) async {
    try {
      await acao();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
    }
  }

  // Detalhes do item (ingredientes removidos / complementos) em coluna com
  // marcadores, no mesmo formato da página do carrinho.
  Widget _listaDetalhe(ThemeData theme, String titulo, List<String> itens) {
    final cor = theme.colorScheme.outline.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: cor)),
          ...itens.map((e) =>
              Text('• $e', style: TextStyle(fontSize: 11, color: cor))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cor = corPedido(pedido);
    final aceitar = pedido.status == 'aceitar';

    return InkWell(
      // Qualquer parte do card abre a descrição do pedido.
      onTap: () => context.push('/pedidoDescricao', extra: pedido),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: cor, width: 6)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(pedido.nomeCliente,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
                Text(rotuloStatus(pedido),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.outline)),
                // Botão para avançar o status do pedido (aceito → preparando →
                // entregando). Não aparece para pedidos aguardando aceite nem
                // para os já em entrega (finalização exige o código).
                if (!aceitar && pedido.status != 'entregando')
                  PopupMenuButton<String>(
                    icon: Icon(Icons.swap_horiz_rounded,
                        size: 20, color: theme.colorScheme.primary),
                    tooltip: 'Alterar status',
                    onSelected: (status) => _acao(
                        context,
                        () => ref
                            .read(pedidoRecebidoProvider.notifier)
                            .definirStatus(pedido.id, status)),
                    itemBuilder: (_) => pedido.status == 'aceito'
                        ? const [
                            PopupMenuItem(
                                value: 'preparando',
                                child: Text('Preparando')),
                          ]
                        : const [
                            PopupMenuItem(
                                value: 'entregando',
                                child: Text('Entregando')),
                          ],
                  ),
              ],
            ),
            Text(horaFormatada(pedido),
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.outline.withValues(alpha: 0.7))),
            const SizedBox(height: 6),
            ...pedido.itens.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(item.nome,
                              style: const TextStyle(fontSize: 13))),
                          Text('qtde: ${item.qtde}',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      if (item.ingredientesRemovidos.isNotEmpty)
                        _listaDetalhe(
                            theme, 'Remover:', item.ingredientesRemovidos),
                      if (item.complementos.isNotEmpty)
                        _listaDetalhe(
                            theme, 'Complementos:', item.complementos),
                    ],
                  ),
                )),
            if (aceitar) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0392B),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _acao(
                          context,
                          () => ref
                              .read(pedidoRecebidoProvider.notifier)
                              .rejeitar(pedido.id)),
                      child: const Text('NÃO'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A8C7A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _acao(
                          context,
                          () => ref
                              .read(pedidoRecebidoProvider.notifier)
                              .aceitar(pedido.id)),
                      child: const Text('SIM'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
