import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiosque_app/data/api/models/pedido_models.dart';
import 'package:quiosque_app/data/api/pedido_api.dart';
import 'package:quiosque_app/data/services/notification_service.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';

/// Pedidos recebidos pelo quiosque, carregados de
/// `GET /quiosques/me/pedidos/ativos` (FUNCIONARIO). Aceite, troca de status,
/// finalização e cancelamento são feitos via [PedidoApi].
final pedidoRecebidoProvider =
    AsyncNotifierProvider<PedidoRecebidoNotifier, List<PedidoRecebido>>(
        PedidoRecebidoNotifier.new);

class PedidoRecebidoNotifier extends AsyncNotifier<List<PedidoRecebido>> {
  PedidoApi get _api => PedidoApi.instance;

  @override
  Future<List<PedidoRecebido>> build() {
    // Recarrega a lista quando chega uma notificação push (FCM) do back-end
    // (novo pedido / pedido cancelado pelo cliente).
    final sub = NotificationService.instance.aoReceberMensagem
        .listen((_) => ref.invalidateSelf());
    ref.onDispose(sub.cancel);
    return _carregar();
  }

  Future<List<PedidoRecebido>> _carregar() async {
    final lista = await _api.doQuiosqueAtivos();
    return lista.map(_mapear).toList();
  }

  /// Recarrega a lista passando pelo estado de carregamento. Usado pelo botão
  /// "Tentar novamente" quando a busca falha (ex.: sem conexão).
  Future<void> recarregar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_carregar);
  }

  /// Recarrega a lista em segundo plano, sem passar pelo estado de carregamento
  /// (evita o flash do spinner). Usado pelo polling periódico da tela de
  /// pedidos para que pedidos novos apareçam sem recarregar a página na mão.
  /// Se a busca falhar, mantém a lista atual e tenta de novo no próximo ciclo.
  Future<void> atualizarSilencioso() async {
    try {
      state = AsyncValue.data(await _carregar());
    } catch (_) {
      // Mantém a lista exibida; o próximo ciclo de polling tenta novamente.
    }
  }

  /// Aceita um pedido novo (CRIADO → ACEITO).
  Future<void> aceitar(String id) =>
      _executar(() => _api.atualizarStatus(id, StatusPedidoApi.aceito));

  /// Recusa um pedido ainda não aceito.
  Future<void> rejeitar(String id) => _executar(() => _api.rejeitar(id));

  /// Troca o status de um pedido já aceito (aceito / preparando / entregando).
  Future<void> definirStatus(String id, String status) =>
      _executar(() => _api.atualizarStatus(id, _statusApi(status)));

  /// Marca como finalizado. Usado quando não há código a validar.
  Future<void> finalizar(String id) =>
      _executar(() => _api.atualizarStatus(id, StatusPedidoApi.finalizado));

  /// Cancela um pedido já aceito, informando o motivo (opcional).
  Future<void> cancelar(String id, {String motivo = ''}) =>
      _executar(() => _api.cancelarComMotivo(id, motivo));

  /// Valida o código de entrega informado pelo cliente. Em caso de sucesso o
  /// back-end finaliza o pedido; recarregamos a lista para refletir a baixa.
  Future<bool> validarCodigo(String id, String codigo) async {
    final ok = await _api.validarCodigo(id, codigo);
    if (ok) ref.invalidateSelf();
    return ok;
  }

  Future<void> _executar(Future<Object?> Function() acao) async {
    await acao();
    ref.invalidateSelf();
  }

  PedidoRecebido _mapear(PedidoView p) => PedidoRecebido(
        id: p.id,
        nomeCliente: p.nomeCliente,
        hora: (p.dataHoraPedido ?? DateTime.now()).toIso8601String(),
        status: _statusApp(p.status),
        // O código de verificação não é exposto na listagem; a validação é
        // feita pelo back-end (`POST /pedidos/{id}/validar-codigo`).
        codigo: '',
        itens: p.itens.map(_mapearItem).toList(),
        interno: p.interno,
        clienteLat: p.latitudeEntrega == 0 ? null : p.latitudeEntrega,
        clienteLng: p.longitudeEntrega == 0 ? null : p.longitudeEntrega,
      );

  ItemPedidoRecebido _mapearItem(ItemPedidoView i) => ItemPedidoRecebido(
        nome: i.nome ?? '',
        qtde: i.quantidade,
        valorUnitario: ((i.valorUnit ?? 0) * 100).round(),
        ingredientesRemovidos: i.ingredientesRemovidos,
        complementos: i.acompanhamentos,
      );

  /// Converte o status da API para o vocabulário usado nas telas.
  static String _statusApp(StatusPedidoApi s) {
    switch (s) {
      case StatusPedidoApi.criado:
        return 'aceitar';
      case StatusPedidoApi.aceito:
        return 'aceito';
      case StatusPedidoApi.preparando:
        return 'preparando';
      case StatusPedidoApi.emEntrega:
        return 'entregando';
      case StatusPedidoApi.finalizado:
      case StatusPedidoApi.avaliado:
        return 'finalizado';
      case StatusPedidoApi.rejeitado:
      case StatusPedidoApi.cancelado:
        return 'cancelado';
    }
  }

  /// Converte o status das telas para o enum da API.
  static StatusPedidoApi _statusApi(String status) {
    switch (status) {
      case 'aceito':
        return StatusPedidoApi.aceito;
      case 'preparando':
        return StatusPedidoApi.preparando;
      case 'entregando':
        return StatusPedidoApi.emEntrega;
      case 'finalizado':
        return StatusPedidoApi.finalizado;
      case 'cancelado':
        return StatusPedidoApi.cancelado;
      default:
        return StatusPedidoApi.criado;
    }
  }
}
