import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiosque_app/data/api/funcionario_api.dart';
import 'package:quiosque_app/data/api/models/funcionario_models.dart';
import 'package:quiosque_app/src/shared/models/funcionario.dart';

/// Funcionários do quiosque, carregados de `GET /quiosques/me/funcionarios`
/// (apenas GERENTE). Criação/edição/remoção via `FuncionarioApi`.
final funcionariosProvider =
    AsyncNotifierProvider<FuncionariosNotifier, List<Funcionario>>(
        FuncionariosNotifier.new);

class FuncionariosNotifier extends AsyncNotifier<List<Funcionario>> {
  // A API gera a senha do funcionário no servidor, mas o RegisterDTO exige um
  // password não-vazio na validação. Enviamos este placeholder (ignorado).
  static const _senhaPlaceholder = 'Trocar@123';

  @override
  Future<List<Funcionario>> build() => _carregar();

  Future<List<Funcionario>> _carregar() async {
    final lista = await FuncionarioApi.instance.listar();
    return lista.map(_mapear).toList();
  }

  Funcionario _mapear(FuncionarioView f) => Funcionario(
        id: f.id,
        nomeCompleto: f.nome,
        email: f.email,
        cargo: Cargo.fromRole(f.role),
        telefone: f.telefone ?? '',
        imagem: f.imagem,
        // O login é o próprio e-mail; a senha (texto puro gerado pelo sistema)
        // agora é retornada pela API para reexibição na gestão.
        usuario: f.email,
        senha: f.senha ?? '',
      );

  /// Cadastra um funcionário e devolve a senha provisória gerada pela API.
  Future<String?> adicionar({
    required String nomeCompleto,
    required String email,
    required Cargo cargo,
    required String telefone,
  }) async {
    final criado = await FuncionarioApi.instance.criar(
      nome: nomeCompleto,
      email: email,
      senha: _senhaPlaceholder,
      role: cargo.roleApi,
      telefone: telefone,
    );
    ref.invalidateSelf();
    return criado.senha;
  }

  /// Atualiza um funcionário. A API valida o telefone como obrigatório, por
  /// isso ele é exigido no formulário mesmo na edição.
  Future<void> atualizar({
    required String id,
    required String nomeCompleto,
    required String email,
    required Cargo cargo,
    required String telefone,
  }) async {
    await FuncionarioApi.instance.atualizar(
      id,
      nome: nomeCompleto,
      email: email,
      senha: _senhaPlaceholder,
      role: cargo.roleApi,
      telefone: telefone,
    );
    ref.invalidateSelf();
  }

  Future<void> remover(String id) async {
    await FuncionarioApi.instance.excluir(id);
    ref.invalidateSelf();
  }
}
