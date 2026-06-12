import 'package:client_app/data/services/api_client.dart';

class NotificationRepository {
  static final NotificationRepository instance = NotificationRepository._init();

  final ApiClient _api = ApiClient.instance;

  NotificationRepository._init();

  /// Registra (ou atualiza) o token FCM deste dispositivo no back-end.
  ///
  /// `POST /me/notification-token` (o JWT é injetado pelo [ApiClient]).
  Future<void> registrarToken({
    required String token,
    required String plataforma,
    required String jwt,
  }) async {
    // O back-end (NotificationTokenDTO) espera apenas `token`.
    await _api.post('/me/notification-token', body: {'token': token});
  }

  /// Remoção do token no logout.
  ///
  /// `ENDPOINTS.md` não expõe um endpoint para apagar o token no servidor; o
  /// token FCM é invalidado localmente em [NotificationService.removerToken]
  /// (`deleteToken`). Mantido como no-op para não quebrar o fluxo de logout.
  Future<void> removerToken({
    required String token,
    required String jwt,
  }) async {
    // Sem endpoint correspondente em ENDPOINTS.md.
  }
}
