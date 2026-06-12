import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:client_app/data/repositories/notification_repository.dart';
import 'package:client_app/data/services/cliente_service.dart';
import 'package:client_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Resultado da verificação/solicitação da permissão de notificação.
enum StatusPermissao {
  autorizada,
  negada,
  naoDeterminada,
}

@pragma('vm:entry-point')
Future<void> firebaseMensagemBackgroundHandler(RemoteMessage message) async {
  // Roda em um isolate separado, então precisa inicializar o Firebase de novo.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('[FCM] mensagem em background: ${message.messageId}');
}

class NotificationService {
  static final NotificationService instance = NotificationService._init();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final NotificationRepository _repository = NotificationRepository.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Canal padrão de notificações no Android (obrigatório no Android 8+).
  static const AndroidNotificationChannel _canal = AndroidNotificationChannel(
    'canal_padrao',
    'Notificações',
    description: 'Notificações gerais do aplicativo',
    importance: Importance.high,
  );

  /// Guarda localmente o último token JÁ enviado ao back-end, para não
  /// reenviar à toa quando ele não mudou.
  static const _tokenEnviadoKey = 'fcm_token_enviado';

  /// Emite o `data` da notificação quando o usuário TOCA nela (app rodando).
  /// Um widget Riverpod escuta isso para decidir a navegação.
  final StreamController<Map<String, dynamic>> _toqueController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get aoTocarNotificacao => _toqueController.stream;

  /// Emite o `data` sempre que chega uma notificação de mudança de status de
  /// pedido (`tipo: STATUS_PEDIDO`) com o app em FOREGROUND, mesmo sem o
  /// usuário tocar nela. Um widget Riverpod escuta isso para recarregar a
  /// lista de pedidos automaticamente.
  final StreamController<Map<String, dynamic>> _statusPedidoController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get aoAtualizarStatusPedido =>
      _statusPedidoController.stream;

  /// Toque que abriu o app a partir do estado ENCERRADO. Como pode chegar antes
  /// de existir um listener, fica guardado aqui até alguém consumir.
  Map<String, dynamic>? _toqueInicial;

  NotificationService._init();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Chamado uma vez no startup do app (antes do runApp).
  Future<void> inicializar() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      await _configurarNotificacoesLocais();

      FirebaseMessaging.onBackgroundMessage(firebaseMensagemBackgroundHandler);

      FirebaseMessaging.onMessage.listen((message) {
        mostrarNotificacaoLocal(message);
        _tratarMensagemDeDados(message);
      });

      // Toque na notificação com o app em BACKGROUND.
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _toqueController.add(message.data),
      );

      // Toque na notificação que abriu o app a partir do estado ENCERRADO.
      final inicial = await FirebaseMessaging.instance.getInitialMessage();
      if (inicial != null) _toqueInicial = inicial.data;

      // O FCM rotaciona o token de tempos em tempos -> reenvia ao back-end.
      _messaging.onTokenRefresh.listen((_) => sincronizarToken());
    } catch (e) {
      print('[NotificationService] Firebase não inicializado: $e');
    }
  }

  /// Pede a permissão de notificação, mas só mostra o diálogo do sistema se
  /// ainda não tiver sido perguntado. Se já estiver negada, não insiste
  /// (o diálogo não apareceria de qualquer forma) e devolve [StatusPermissao.negada]
  Future<StatusPermissao> solicitarPermissao() async {
    final NotificationSettings atual;
    try {
      atual = await _messaging.getNotificationSettings();
    } catch (e) {
      // Firebase pode não estar configurado ainda (flutterfire configure).
      print('[NotificationService] permissão indisponível: $e');
      return StatusPermissao.naoDeterminada;
    }

    switch (atual.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return StatusPermissao.autorizada;
      case AuthorizationStatus.denied:
        return StatusPermissao.negada;
      case AuthorizationStatus.notDetermined:
        final settings = await _messaging.requestPermission();
        final ok =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
                settings.authorizationStatus == AuthorizationStatus.provisional;
        return ok ? StatusPermissao.autorizada : StatusPermissao.negada;
    }
  }

  Future<StatusPermissao> statusPermissao() async {
    final atual = await _messaging.getNotificationSettings();
    switch (atual.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return StatusPermissao.autorizada;
      case AuthorizationStatus.denied:
        return StatusPermissao.negada;
      default:
        return StatusPermissao.naoDeterminada;
    }
  }

  /// Garante que o back-end tem o token atual deste dispositivo.
  ///
  /// Só envia se houver usuário logado (JWT presente) e se o token mudou desde
  /// o último envio, evitando requisições repetidas.
  Future<void> sincronizarToken() async {
    try {
      final jwt = await ClienteService.instance.obterJWT();
      if (jwt == null || jwt.isEmpty) return;

      final tokenAtual = await _messaging.getToken();
      if (tokenAtual == null) return;

      final tokenEnviado = await _secureStorage.read(key: _tokenEnviadoKey);
      if (tokenAtual == tokenEnviado) return;

      await _repository.registrarToken(
        token: tokenAtual,
        plataforma: _plataforma(),
        jwt: jwt,
      );
      await _secureStorage.write(key: _tokenEnviadoKey, value: tokenAtual);
    } catch (e) {
      print('[NotificationService] erro ao sincronizar token: $e');
    }
  }

  /// Remove o token no logout para o próximo usuário deste aparelho não
  /// receber notificações do usuário anterior.
  ///
  /// Importante: chamar ANTES de apagar o JWT do cliente.
  Future<void> removerToken() async {
    try {
      final jwt = await ClienteService.instance.obterJWT();
      final token = await _messaging.getToken();
      if (jwt != null && jwt.isNotEmpty && token != null) {
        await _repository.removerToken(token: token, jwt: jwt);
      }
      await _secureStorage.delete(key: _tokenEnviadoKey);
      await _messaging.deleteToken();
    } catch (e) {
      print('[NotificationService] erro ao remover token: $e');
    }
  }

  /// Inicializa o plugin local e cria o canal de notificações no Android.
  Future<void> _configurarNotificacoesLocais() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _aoTocarNotificacaoLocal,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_canal);
  }

  /// Exibe uma notificação local a partir de uma mensagem recebida em foreground.
  void mostrarNotificacaoLocal(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return; // mensagem só com 'data' não exibe banner

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _canal.id,
          _canal.name,
          channelDescription: _canal.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  /// Repassa o `data` de uma mensagem recebida em FOREGROUND para quem estiver
  /// escutando [aoAtualizarStatusPedido], caso seja uma notificação de
  /// mudança de status de pedido (`tipo: STATUS_PEDIDO`).
  void _tratarMensagemDeDados(RemoteMessage message) {
    final dados = message.data;
    if (dados.isEmpty) return;
    if (dados['tipo'] != 'STATUS_PEDIDO') return;
    _statusPedidoController.add(dados);
  }

  /// Chamado quando o usuário toca em uma notificação LOCAL (exibida em
  /// foreground). Decodifica o payload e repassa para o stream de toques.
  void _aoTocarNotificacaoLocal(NotificationResponse resposta) {
    final payload = resposta.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final dados = jsonDecode(payload) as Map<String, dynamic>;
      _toqueController.add(dados);
    } catch (e) {
      print('[NotificationService] payload inválido: $e');
    }
  }

  /// Consome (e limpa) o toque que abriu o app a partir do estado encerrado.
  Map<String, dynamic>? consumirToqueInicial() {
    final toque = _toqueInicial;
    _toqueInicial = null;
    return toque;
  }

  String _plataforma() {
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    return 'OUTRO';
  }
}
