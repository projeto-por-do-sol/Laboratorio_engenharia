/// Configuração de acesso à API "Por do Sol".
///
/// A base URL muda conforme onde o app roda:
/// - Emulador Android: `http://10.0.2.2:8080` (10.0.2.2 é o alias do host).
/// - Emulador iOS / Flutter Web / desktop: `http://localhost:8080`.
/// - Dispositivo físico: o IP da máquina na rede local (ex.: `http://192.168.0.10:8080`).
///
/// Pode ser sobrescrita em tempo de compilação com:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080`
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
