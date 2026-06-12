import 'package:quiosque_app/data/repositories/quiosque_repository.dart';
import 'package:quiosque_app/src/shared/models/quiosque_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

class QuiosqueService {
  static final QuiosqueService instance = QuiosqueService._init();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final QuiosqueRepository _repository = QuiosqueRepository.instance;

  static const _jwtKey = 'jwt_token';

  QuiosqueService._init();

  Future<void> salvarJWT(String token) async {
    await _secureStorage.write(key: _jwtKey, value: token);
  }

  Future<String?> obterJWT() async {
    return await _secureStorage.read(key: _jwtKey);
  }

  Future<void> deletarJWT() async {
    await _secureStorage.delete(key: _jwtKey);
  }

  Future<bool> estaLogado() async {
    final token = await obterJWT();
    return token != null && token.isNotEmpty;
  }

  Future<QuiosqueModel?> buscarQuiosque() => _repository.buscarQuiosque();

  Future<void> salvarQuiosque(QuiosqueModel quiosque) async {
    final existente = await _repository.buscarQuiosque();
    if (existente == null) {
      await _repository.inserirQuiosque(quiosque);
    } else {
      await _repository.atualizarQuiosque(quiosque.copyWith(id: existente.id));
    }
  }

  Future<void> deletarDadosQuiosque() async {
    await deletarJWT();
    await _repository.deletarQuiosque();
  }

  /// Garante que o serviço de localização está ativo e que temos permissão.
  /// Retorna `false` quando não é possível obter localização.
  Future<bool> _localizacaoDisponivel() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    return permission != LocationPermission.deniedForever;
  }

  /// Último ponto conhecido pelo dispositivo. Retorna instantaneamente (pode ser
  /// um pouco desatualizado) e serve para mostrar algo antes de um fix novo.
  Future<Position?> obterUltimaLocalizacao() async {
    if (!await _localizacaoDisponivel()) return null;
    return Geolocator.getLastKnownPosition();
  }

  /// Obtém um fix de localização atual. Aplica um [timeLimit] para não ficar
  /// pendurado indefinidamente quando o sinal de GPS está fraco; nesse caso
  /// retorna `null` em vez de travar.
  Future<Position?> obterLocalizacao() async {
    if (!await _localizacaoDisponivel()) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Timeout ou falha ao adquirir o fix.
      return null;
    }
  }
}
