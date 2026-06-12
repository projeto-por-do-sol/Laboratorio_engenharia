import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/src/shared/models/item_quiosque.dart';
import 'package:client_app/src/shared/models/quiosque_model.dart';

/// Acesso remoto aos quiosques e ao cardápio (`ENDPOINTS.md` › Quiosques).
///   - `listarQuiosques()` -> `GET /quiosques/nearby`
///   - `listarItensQuiosque(id)` -> `GET /quiosques/{id}/categorias`
class QuiosqueRepository {
  static final QuiosqueRepository instance = QuiosqueRepository._init();

  final ApiClient _api = ApiClient.instance;

  QuiosqueRepository._init();

  /// `GET /quiosques/nearby?latUsuario=&lonUsuario=&raioM=` (público).
  Future<List<QuiosqueModel>> listarQuiosques({
    double? latUsuario,
    double? lonUsuario,
    int raioM = 10000,
  }) async {
    final resp = await _api.get(
      '/quiosques/nearby',
      autenticar: false,
      query: {
        'latUsuario': latUsuario,
        'lonUsuario': lonUsuario,
        'raioM': raioM,
      },
    );
    return _extrairLista(resp)
        .map((e) => QuiosqueModel.fromJson(e))
        .toList();
  }

  /// `GET /quiosques/{id}/categorias` (público). Achata as categorias do
  /// cardápio em uma lista de itens, preenchendo `secaoItem` (nome da
  /// categoria) e `idQuiosque`.
  Future<List<ItemQuiosque>> listarItensQuiosque(String idQuiosque) async {
    final resp = await _api.get(
      '/quiosques/$idQuiosque/categorias',
      autenticar: false,
    );

    final categorias = _extrairLista(resp);
    final itens = <ItemQuiosque>[];

    for (final categoria in categorias) {
      final nomeCategoria =
          (categoria['nome'] ?? categoria['secaoItem'] ?? '').toString();
      final itensCategoria = (categoria['itens'] as List?) ?? const [];

      for (final item in itensCategoria) {
        final mapa = (item as Map).cast<String, dynamic>();
        itens.add(ItemQuiosque.fromJson({
          ...mapa,
          'idQuiosque': mapa['idQuiosque'] ?? idQuiosque,
          'secaoItem': mapa['secaoItem'] ?? nomeCategoria,
        }));
      }
    }

    return itens;
  }

  /// Aceita tanto uma lista pura quanto um objeto que a embrulhe
  /// (`content` / `data` / `quiosques` / `categorias` / `itens`).
  List<Map<String, dynamic>> _extrairLista(dynamic resp) {
    dynamic lista = resp;
    if (resp is Map) {
      lista = resp['content'] ??
          resp['data'] ??
          resp['quiosques'] ??
          resp['categorias'] ??
          resp['itens'] ??
          const [];
    }
    if (lista is! List) return const [];
    return lista.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }
}
