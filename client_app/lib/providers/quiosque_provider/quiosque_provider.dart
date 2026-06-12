import 'package:client_app/data/services/quiosque_service.dart';
import 'package:client_app/src/shared/models/item_quiosque.dart';
import 'package:client_app/src/shared/models/quiosque_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiosque_provider.g.dart';

/// Lista de quiosques exibida na tela de início.
@Riverpod(keepAlive: true)
Future<List<QuiosqueModel>> quiosques(Ref ref) async {
  return QuiosqueService.instance.buscarQuiosques();
}

/// Itens vendidos em um quiosque específico.
@riverpod
Future<List<ItemQuiosque>> itensQuiosque(Ref ref, String idQuiosque) async {
  return QuiosqueService.instance.buscarItensQuiosque(idQuiosque);
}
