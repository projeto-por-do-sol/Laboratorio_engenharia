import 'dart:io';

import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/providers/cliente_provider/cliente_provider.dart';
import 'package:client_app/src/shared/widget/button.dart';
import 'package:client_app/src/shared/widget/input.dart';
import 'package:client_app/src/shared/widget/inputImagem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Cadastro extends ConsumerStatefulWidget {
  const Cadastro({super.key});

  @override
  ConsumerState<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends ConsumerState<Cadastro> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _fotoSelecionada;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cpfController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                CustomInput(
                  label: "Nome Completo:",
                  controller: nameController,
                  isRequired: true,
                  typeText: TextCapitalization.words,
                ),

                const SizedBox(height: 15),

                CustomInput(
                  label: "E-mail:",
                  controller: emailController,
                  isRequired: true,
                  isEmail: true,
                ),

                const SizedBox(height: 15),

                CustomInput(
                  label: "Telefone:",
                  controller: phoneController,
                  isRequired: true,
                  isPhone: true,
                ),

                const SizedBox(height: 15),

                CustomInput(
                  label: "CPF:",
                  controller: cpfController,
                  isRequired: true,
                  isCPF: true,
                ),

                const SizedBox(height: 15),

                CustomInput(
                  label: "Senha:",
                  controller: passwordController,
                  isRequired: true,
                  isPassword: true,
                ),

                const SizedBox(height: 15),

                CustomInput(
                  label: "Confirmar senha:",
                  controller: passwordConfirmController,
                  isRequired: true,
                  isPassword: true,
                ),

                const SizedBox(height: 15),

                InputFotoPerfil(
                  onImagemSelecionada: (arquivo) => _fotoSelecionada = arquivo,
                ),

                const SizedBox(height: 20),

                CustomButton(
                  label: "criar conta",
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final router = GoRouter.of(context);

                    void aviso(String msg, {bool erro = false}) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            msg.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: erro
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }

                    if (passwordController.text != passwordConfirmController.text) {
                      aviso("As senhas não coincidem!");
                      return;
                    }

                    if (!_formKey.currentState!.validate()) return;

                    try {
                      await ref.read(clienteProvider.notifier).cadastrar(
                            nomeCompleto: nameController.text.trim(),
                            email: emailController.text.trim(),
                            telefone: phoneController.text.trim(),
                            cpf: cpfController.text
                                .replaceAll(RegExp(r'[^0-9]'), ''),
                            senha: passwordController.text.trim(),
                          );

                      // Já logado: envia a foto de perfil, se houver.
                      if (_fotoSelecionada != null) {
                        try {
                          await ref
                              .read(clienteProvider.notifier)
                              .enviarImagemPerfil(_fotoSelecionada!);
                        } catch (_) {/* foto é opcional; ignora falha */}
                      }

                      router.go('/inicio');
                    } on ApiException catch (e) {
                      // O back-end sinaliza dados duplicados (e-mail/CPF/telefone)
                      // como 403/409/500 sem corpo; 400 = validação.
                      final duplicado = e.statusCode == 409 ||
                          e.statusCode == 403 ||
                          e.statusCode == 500;
                      aviso(
                        duplicado
                            ? "E-mail, CPF ou telefone já cadastrado."
                            : "Erro ao criar conta. Verifique os dados.",
                        erro: true,
                      );
                    } catch (_) {
                      aviso("Não foi possível conectar ao servidor.",
                          erro: true);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
