import 'dart:async';

import 'package:client_app/MyApp.dart';
import 'package:client_app/data/services/notification_service.dart';
import 'package:client_app/providers/historico_provider/historico_provider.dart';
import 'package:client_app/providers/pedido_provider/pedido_provider.dart';
import 'package:client_app/src/shared/models/pedidos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Envolve o app e:
///  - reage ao TOQUE em uma notificação, navegando para:
///    - `/avaliarPedidos` se o pedido referido estiver cancelado;
///    - `/pedidos` caso contrário;
///  - recarrega a lista de pedidos automaticamente quando chega uma
///    notificação de mudança de status (`STATUS_PEDIDO`) ou quando o app
///    volta a ficar em foreground, para a tela de pedidos refletir o status
///    atualizado sem o usuário precisar dar refresh manual.
///
/// Escuta tanto os toques que chegam com o app rodando (stream do
/// [NotificationService]) quanto o toque que abriu o app do estado encerrado.
class NotificacaoListener extends ConsumerStatefulWidget {
  final Widget child;

  const NotificacaoListener({super.key, required this.child});

  @override
  ConsumerState<NotificacaoListener> createState() =>
      _NotificacaoListenerState();
}

class _NotificacaoListenerState extends ConsumerState<NotificacaoListener>
    with WidgetsBindingObserver {
  StreamSubscription<Map<String, dynamic>>? _sub;
  StreamSubscription<Map<String, dynamic>>? _statusSub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Toques com o app já rodando (foreground/background).
    _sub = NotificationService.instance.aoTocarNotificacao.listen(_tratarToque);

    // Mudança de status com o app em foreground: recarrega a lista de
    // pedidos sem precisar de toque/refresh manual.
    _statusSub = NotificationService.instance.aoAtualizarStatusPedido
        .listen((_) => _recarregarPedidos());

    // Toque que abriu o app a partir do estado encerrado: tratamos após o
    // primeiro frame, garantindo que o router já esteja pronto para navegar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inicial = NotificationService.instance.consumirToqueInicial();
      if (inicial != null) _tratarToque(inicial);
    });
  }

  /// Recarrega os pedidos ativos e invalida o histórico (caso o status
  /// recebido tenha movido o pedido para finalizado/cancelado).
  void _recarregarPedidos() {
    ref.read(pedidoProvider.notifier).recarregar();
    ref.invalidate(historicoProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App voltou ao foreground: pode ter chegado push enquanto estava em
    // background, então recarrega para mostrar o status mais recente.
    if (state == AppLifecycleState.resumed) {
      _recarregarPedidos();
    }
  }

  Future<void> _tratarToque(Map<String, dynamic> dados) async {
    final idPedido = dados['idPedido'] as String?;

    // Sem id não dá para localizar o pedido: leva para a lista de pedidos.
    if (idPedido == null) {
      appRouter.go('/pedidos');
      return;
    }

    // Garante que a lista (e o histórico) reflitam o status mais recente
    // antes de decidir a navegação.
    _recarregarPedidos();

    // 1) Procura o pedido na lista local (sqflite via provider).
    final pedidos = await ref.read(pedidoProvider.future);
    PedidosModel? pedido;
    for (final p in pedidos) {
      if (p.idPedido == idPedido) {
        pedido = p;
        break;
      }
    }

    // 2) Não achou localmente -> busca no back-end.
    pedido ??=
        await ref.read(pedidoProvider.notifier).buscarPedidoNoBackend(idPedido);

    final cancelado = pedido != null && pedido.cancelado;

    if (cancelado) {
      appRouter.push('/avaliarPedidos', extra: pedido);
    } else {
      appRouter.go('/pedidos');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
