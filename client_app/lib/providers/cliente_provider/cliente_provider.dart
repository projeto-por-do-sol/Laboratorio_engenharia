import 'dart:io';

import 'package:client_app/data/services/cliente_service.dart';
import 'package:client_app/data/services/notification_service.dart';
import 'package:client_app/providers/carrinho_provider/carrinho_provider.dart';
import 'package:client_app/src/shared/models/cliente_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clienteProvider =
    AsyncNotifierProvider<ClienteNotifier, ClienteModel?>(ClienteNotifier.new);

class ClienteNotifier extends AsyncNotifier<ClienteModel?> {
  @override
  Future<ClienteModel?> build() async {
    final logado = await ClienteService.instance.estaLogado();
    if (!logado) return null;
    // Tenta atualizar pelo back-end (GET /me); cai para o cache local offline.
    return ClienteService.instance.carregarPerfil();
  }

  /// Login real (`POST /auth/login`). Lança [ApiException] em credenciais
  /// inválidas (401) para a tela tratar.
  Future<void> login({
    required String login,
    required String senha,
  }) async {
    final cliente =
        await ClienteService.instance.login(login: login, senha: senha);
    state = AsyncData(cliente);
    await _configurarNotificacoes();
  }

  /// Cadastro real (`POST /auth/register`) com login automático.
  Future<void> cadastrar({
    required String nomeCompleto,
    required String email,
    required String telefone,
    required String cpf,
    required String senha,
  }) async {
    final cliente = await ClienteService.instance.cadastrar(
      nomeCompleto: nomeCompleto,
      email: email,
      telefone: telefone,
      cpf: cpf,
      senha: senha,
    );
    state = AsyncData(cliente);
    await _configurarNotificacoes();
  }

  Future<void> atualizarPerfil(ClienteModel cliente) async {
    final atualizado = await ClienteService.instance.atualizarPerfil(cliente);
    state = AsyncData(atualizado);
  }

  Future<void> enviarImagemPerfil(File arquivo) async {
    final atualizado =
        await ClienteService.instance.enviarImagemPerfil(arquivo);
    state = AsyncData(atualizado);
  }

  Future<void> removerImagemPerfil() async {
    final atualizado = await ClienteService.instance.removerImagemPerfil();
    state = AsyncData(atualizado);
  }

  Future<void> logout() async {
    // Remove o token do back-end antes de apagar o JWT (a remoção precisa dele).
    await NotificationService.instance.removerToken();
    await ClienteService.instance.deletarDadosCliente();
    _limparEstadoLocal();
    state = const AsyncData(null);
  }

  Future<void> deletarConta() async {
    await NotificationService.instance.removerToken();
    await ClienteService.instance.deletarConta();
    _limparEstadoLocal();
    state = const AsyncData(null);
  }

  void _limparEstadoLocal() {
    // Só o carrinho precisa ser limpo explicitamente. Pedidos e histórico
    // observam o clienteProvider e voltam para [] sozinhos quando o usuário
    // fica nulo — ler pedidoProvider aqui criaria dependência circular
    // (pedidoProvider já depende de clienteProvider).
    ref.read(carrinhoProvider.notifier).limparCarrinho();
  }

  /// Agora que há usuário logado, pede permissão e registra o token FCM.
  /// Em try/catch para que uma falha de notificação NUNCA quebre o login.
  Future<void> _configurarNotificacoes() async {
    try {
      await NotificationService.instance.solicitarPermissao();
      await NotificationService.instance.sincronizarToken();
    } catch (e) {
      print('[ClienteNotifier] falha ao configurar notificações no login: $e');
    }
  }
}
