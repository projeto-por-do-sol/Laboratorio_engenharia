import 'package:quiosque_app/data/api/auth_api.dart';
import 'package:quiosque_app/data/api/quiosque_api.dart';
import 'package:quiosque_app/data/services/quiosque_service.dart';
import 'package:quiosque_app/providers/funcionarios_provider/funcionarios_provider.dart';
import 'package:quiosque_app/providers/historico_provider/historico_provider.dart';
import 'package:quiosque_app/providers/pagina_quiosque_provider/pagina_quiosque_provider.dart';
import 'package:quiosque_app/providers/pedido_recebido_provider/pedido_recebido_provider.dart';
import 'package:quiosque_app/providers/sessao_provider/sessao_provider.dart';
import 'package:quiosque_app/src/shared/models/quiosque_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final quiosqueProvider =
    AsyncNotifierProvider<QuiosqueNotifier, QuiosqueModel?>(QuiosqueNotifier.new);

class QuiosqueNotifier extends AsyncNotifier<QuiosqueModel?> {
  @override
  Future<QuiosqueModel?> build() async {
    final logado = await QuiosqueService.instance.estaLogado();
    if (!logado) return null;
    return QuiosqueService.instance.buscarQuiosque();
  }

  Future<void> login({
    required String nomeQuiosque,
    required String email,
    required String telefone,
    String token = 'mock_jwt_token',
  }) async {
    await QuiosqueService.instance.salvarJWT(token);
    final existente = await QuiosqueService.instance.buscarQuiosque();
    final quiosque = QuiosqueModel(
      id: existente?.id ?? const Uuid().v4(),
      nomeQuiosque: nomeQuiosque,
      email: email,
      telefone: telefone,
    );
    await QuiosqueService.instance.salvarQuiosque(quiosque);
    final salvo = await QuiosqueService.instance.buscarQuiosque();
    state = AsyncData(salvo);
    // Descarta qualquer estado da sessão anterior (inclusive erros em cache de
    // quando não havia token) para que as telas recarreguem com o novo JWT.
    _limparDadosDaSessao();
  }

  // Valores padrão para campos do quiosque não coletados no cadastro (editáveis
  // depois na página do quiosque): horário de funcionamento e raio de entrega.
  static const _horarioAbrePadrao = '08:00';
  static const _horarioFechaPadrao = '18:00';
  static const _distAtendimentoPadrao = 1000;

  /// Cadastro real de um quiosque (proprietário) contra a API:
  /// 1) `POST /auth/register` cria o usuário PROPRIETARIO (sem CPF; o nome do
  ///    responsável é o próprio nome do quiosque);
  /// 2) `POST /auth/login` autentica e devolve o JWT (salvo para os próximos
  ///    requests);
  /// 3) `POST /quiosques` cria o quiosque vinculado ao proprietário (horário e
  ///    raio assumem padrões, ajustáveis depois);
  /// 4) semeia o quiosque local e a sessão (igual ao login).
  Future<void> cadastrar({
    required String nomeQuiosque,
    required String email,
    required String telefone,
    required String cnpj,
    required String senha,
    required String cep,
    required String cidade,
    required String uf,
    required double latitude,
    required double longitude,
  }) async {
    await AuthApi.instance.register(
      nome: nomeQuiosque,
      email: email,
      senha: senha,
      cpf: '',
      role: 'PROPRIETARIO',
      telefone: telefone,
    );

    final token = await AuthApi.instance.login(email: email, senha: senha);
    await QuiosqueService.instance.salvarJWT(token);

    await QuiosqueApi.instance.criar({
      'nome': nomeQuiosque,
      'email': email,
      'cnpj': cnpj,
      'openingTime': _horarioAbrePadrao,
      'closingTime': _horarioFechaPadrao,
      'distAtendimento': _distAtendimentoPadrao,
      'cep': cep,
      'uf': uf,
      'cidade': cidade,
      'latitude': latitude,
      'longitude': longitude,
    });

    // Estabelece a sessão (usuário atual) para que perfil/cargo reflitam o dono.
    final usuario = await AuthApi.instance.me();
    ref.read(usuarioAtualProvider.notifier).definir(usuario);

    final existente = await QuiosqueService.instance.buscarQuiosque();
    final quiosque = QuiosqueModel(
      id: existente?.id ?? const Uuid().v4(),
      nomeQuiosque: nomeQuiosque,
      email: email,
      telefone: telefone,
    );
    await QuiosqueService.instance.salvarQuiosque(quiosque);
    final salvo = await QuiosqueService.instance.buscarQuiosque();
    state = AsyncData(salvo);
    // Mesma limpeza do login: garante que os providers da sessão recarreguem
    // com o token recém-criado, sem reaproveitar erros em cache.
    _limparDadosDaSessao();
  }

  Future<void> atualizarPerfil(QuiosqueModel quiosque) async {
    await QuiosqueService.instance.salvarQuiosque(quiosque);
    final atualizado = await QuiosqueService.instance.buscarQuiosque();
    state = AsyncData(atualizado);
  }

  Future<void> logout() async {
    await QuiosqueService.instance.deletarDadosQuiosque();
    ref.read(usuarioAtualProvider.notifier).definir(null);
    _limparDadosDaSessao();
    state = const AsyncData(null);
  }

  Future<void> deletarConta() async {
    // Exclui a conta no servidor (DELETE /me) antes de limpar o estado local.
    await AuthApi.instance.excluirConta();
    await QuiosqueService.instance.deletarDadosQuiosque();
    ref.read(usuarioAtualProvider.notifier).definir(null);
    _limparDadosDaSessao();
    state = const AsyncData(null);
  }

  /// Descarta os dados carregados da sessão atual para que uma nova sessão não
  /// reaproveite estado (inclusive erros) em cache de outro usuário/token.
  void _limparDadosDaSessao() {
    ref.invalidate(paginaQuiosqueProvider);
    ref.invalidate(pedidoRecebidoProvider);
    ref.invalidate(historicoProvider);
    ref.invalidate(funcionariosProvider);
  }
}
