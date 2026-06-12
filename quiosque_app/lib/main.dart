import 'package:quiosque_app/MyApp.dart';
import 'package:quiosque_app/data/services/notification_service.dart';
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
                + rodar `flutterfire configure` (gera google-services.json)
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase/FCM (atualização automática dos pedidos).
  await NotificationService.instance.inicializar();

  runApp(ProviderScope(child: const MyApp()));
}
