import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:quiosque_app/data/api/auth_api.dart';
import 'package:quiosque_app/data/services/quiosque_service.dart';
import 'package:quiosque_app/firebase_options.dart';

/// Handler de mensagens recebidas com o app em background/encerrado.
/// Roda em um isolate separado, então precisa inicializar o Firebase de novo.
@pragma('vm:entry-point')
Future<void> firebaseMensagemBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Mensagens com bloco `notification` são exibidas pelo próprio sistema;
  // a lista de pedidos é recarregada quando o app volta ao primeiro plano.
}

/// Integração com o FCM (push) para o app do quiosque.
///
/// O back-end envia uma notificação aos aparelhos do quiosque quando um novo
/// pedido chega (ou um pedido é cancelado pelo cliente); ao receber a
/// mensagem, o [pedidoRecebidoProvider] se recarrega sozinho (ele escuta
/// [aoReceberMensagem]).
///
/// É tolerante a falhas: se a inicialização do Firebase falhar por qualquer
/// motivo, apenas loga o erro e o app segue funcionando com atualização
/// manual.
class NotificationService {
  static final NotificationService instance = NotificationService._();

  NotificationService._();

  bool _disponivel = false;

  /// Último token já enviado ao back-end, para não reenviar à toa.
  String? _tokenEnviado;

  final StreamController<RemoteMessage> _mensagensController =
      StreamController<RemoteMessage>.broadcast();

  /// Mensagens push recebidas com o app aberto (ex.: novo pedido).
  Stream<RemoteMessage> get aoReceberMensagem => _mensagensController.stream;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Chamado uma vez no startup do app (antes do runApp).
  Future<void> inicializar() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _disponivel = true;

      FirebaseMessaging.onBackgroundMessage(firebaseMensagemBackgroundHandler);

      // Mensagem recebida com o app em primeiro plano.
      FirebaseMessaging.onMessage.listen(_mensagensController.add);

      // Toque na notificação com o app em background: também repassa, para a
      // lista de pedidos recarregar ao voltar para o app.
      FirebaseMessaging.onMessageOpenedApp.listen(_mensagensController.add);

      // O FCM rotaciona o token de tempos em tempos -> reenvia ao back-end.
      _messaging.onTokenRefresh.listen((_) => sincronizarToken());
    } catch (e) {
      // ignore: avoid_print
      print('[NotificationService] Firebase não inicializado: $e');
    }
  }

  /// Garante que o back-end tem o token de push atual deste dispositivo
  /// (`POST /me/notification-token`). Só envia se houver sessão (JWT) e se o
  /// token mudou desde o último envio.
  Future<void> sincronizarToken() async {
    if (!_disponivel) return;
    try {
      final jwt = await QuiosqueService.instance.obterJWT();
      if (jwt == null || jwt.isEmpty) return;

      // Necessário no Android 13+ para as notificações aparecerem.
      await _messaging.requestPermission();

      final token = await _messaging.getToken();
      if (token == null || token == _tokenEnviado) return;

      await AuthApi.instance.registrarTokenNotificacao(token);
      _tokenEnviado = token;
    } catch (e) {
      // ignore: avoid_print
      print('[NotificationService] erro ao sincronizar token: $e');
    }
  }
}
