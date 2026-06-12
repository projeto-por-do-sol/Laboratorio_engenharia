import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/providers/funcionarios_provider/funcionarios_provider.dart';
import 'package:quiosque_app/providers/sessao_provider/sessao_provider.dart';
import 'package:quiosque_app/src/shared/models/funcionario.dart';
import 'package:quiosque_app/src/shared/widget/button.dart';
import 'package:quiosque_app/src/shared/widget/input.dart';
import 'package:quiosque_app/src/shared/widget/modais.dart';

class FuncionarioFormPage extends ConsumerStatefulWidget {
  final Funcionario? funcionario;

  const FuncionarioFormPage({super.key, this.funcionario});

  bool get editando => funcionario != null;

  @override
  ConsumerState<FuncionarioFormPage> createState() =>
      _FuncionarioFormPageState();
}

class _FuncionarioFormPageState extends ConsumerState<FuncionarioFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  Cargo _cargo = Cargo.funcionario;
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    final f = widget.funcionario;
    if (f != null) {
      _nomeController.text = f.nomeCompleto;
      _emailController.text = f.email;
      _telefoneController.text = f.telefone;
      _cargo = f.cargo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Gerente e dono podem visualizar/definir os dados de login do funcionário.
    final podeVerLogin = ref.watch(cargoAtualProvider).podeGerenciar;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.editando ? 'Editar funcionário' : 'Cadastrar funcionário'),
      ),
      body: Stack(
        children: [
        SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Nome completo:',
                  controller: _nomeController,
                  isRequired: true,
                  typeText: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'E-mail:',
                  controller: _emailController,
                  isRequired: true,
                  isEmail: true,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Telefone:',
                  controller: _telefoneController,
                  isRequired: true,
                  isPhone: true,
                ),
                const SizedBox(height: 12),
                _dropdownCargo(theme),
                // Gerente/dono visualizam os dados de login (gerados
                // automaticamente). Para um funcionário sendo cadastrado, eles
                // ainda não existem e aparecem após o cadastro.
                if (podeVerLogin && widget.editando) ...[
                  const SizedBox(height: 12),
                  _dadosLogin(theme),
                ],
                const SizedBox(height: 24),
                if (widget.editando) ...[
                  CustomButton(
                    label: 'Excluir',
                    icone: Icons.delete_outline,
                    onPressed: _excluir,
                  ),
                  const SizedBox(height: 12),
                ],
                CustomButton(
                  label: widget.editando ? 'Salvar' : 'Adicionar',
                  onPressed: _salvar,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        ),
          if (_processando)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _copiar(String texto, String mensagem) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    }
  }

  // Exibe os dados de login do funcionário (apenas leitura), com botões para
  // copiar o login e a senha.
  Widget _dadosLogin(ThemeData theme) {
    final f = widget.funcionario!;
    Widget linha(String rotulo, String valor,
            {String? copiarTooltip, String? copiarMensagem}) =>
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(rotulo,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(valor.isEmpty ? '-' : valor,
                    style: TextStyle(
                        fontSize: 16, color: theme.colorScheme.primary)),
              ),
              if (valor.isNotEmpty && copiarTooltip != null)
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 20),
                  tooltip: copiarTooltip,
                  onPressed: () => _copiar(valor, copiarMensagem!),
                ),
            ],
          ),
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dados de login', style: theme.textTheme.titleMedium),
          linha('Login:', f.usuario,
              copiarTooltip: 'Copiar login',
              copiarMensagem: 'Login copiado para a área de transferência.'),
          linha('Senha:', f.senha,
              copiarTooltip: 'Copiar senha',
              copiarMensagem: 'Senha copiada para a área de transferência.'),
        ],
      ),
    );
  }

  Widget _dropdownCargo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cargo:', style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          DropdownButtonFormField<Cargo>(
            initialValue: _cargo,
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: theme.colorScheme.outline, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 3),
              ),
            ),
            items: Cargo.atribuiveis
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (c) => setState(() => _cargo = c ?? Cargo.funcionario),
          ),
        ],
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(funcionariosProvider.notifier);

    setState(() => _processando = true);
    try {
      if (widget.editando) {
        await notifier.atualizar(
          id: widget.funcionario!.id,
          nomeCompleto: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          cargo: _cargo,
          telefone: _telefoneController.text.trim(),
        );
        if (mounted) context.pop();
      } else {
        final senha = await notifier.adicionar(
          nomeCompleto: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          cargo: _cargo,
          telefone: _telefoneController.text.trim(),
        );
        if (!mounted) return;
        await mostrarAlerta(context,
            mensagem: 'Funcionário cadastrado!\n\nLogin: '
                '${_emailController.text.trim()}\nSenha provisória: ${senha ?? '-'}',
            icone: Icons.check_circle_outline);
        if (mounted) context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _excluir() async {
    final confirmar = await mostrarModalConfirmacaoDestaque(
      context,
      pergunta: 'Deseja excluir este funcionário?',
    );
    if (confirmar != true || !mounted) return;
    setState(() => _processando = true);
    try {
      await ref
          .read(funcionariosProvider.notifier)
          .remover(widget.funcionario!.id);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }
}
