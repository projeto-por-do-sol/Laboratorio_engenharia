import 'package:client_app/MyApp.dart';
import 'package:client_app/data/services/notification_service.dart';
import 'package:client_app/src/shared/widget/notificacao_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
Pacotes:
  * Material Icons: flutter pub add material_symbols_icons
  * go_router: flutter pub add go_router
  * Riverpod: flutter pub add flutter_riverpod
              flutter pub add riverpod_annotation
              flutter pub add dev:riverpod_generator
              flutter pub add dev:build_runner
  * Push (FCM): flutter pub add firebase_core firebase_messaging
                + rodar `flutterfire configure` (gera firebase_options.dart)
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase/FCM. É tolerante a falhas: enquanto o
  // `flutterfire configure` não for rodado, apenas loga e o app segue normal.
  await NotificationService.instance.inicializar();

  runApp(
    ProviderScope(
      child: const NotificacaoListener(child: MyApp()),
    ),
  );
}