import 'package:client_app/data/repositories/quiosque_repository.dart';
import 'package:client_app/data/services/cliente_service.dart';
import 'package:client_app/src/shared/models/item_quiosque.dart';
import 'package:client_app/src/shared/models/quiosque_model.dart';

class QuiosqueService {
  static final QuiosqueService instance = QuiosqueService._init();

  final QuiosqueRepository _repository = QuiosqueRepository.instance;

  QuiosqueService._init();

  /// Busca os quiosques próximos usando a localização atual do usuário
  /// (quando disponível) para `GET /quiosques/nearby`.
  Future<List<QuiosqueModel>> buscarQuiosques() async {
    final posicao = await ClienteService.instance.obterLocalizacao();
    return _repository.listarQuiosques(
      latUsuario: posicao?.latitude,
      lonUsuario: posicao?.longitude,
    );
  }

  Future<List<ItemQuiosque>> buscarItensQuiosque(String idQuiosque) =>
      _repository.listarItensQuiosque(idQuiosque);
}
