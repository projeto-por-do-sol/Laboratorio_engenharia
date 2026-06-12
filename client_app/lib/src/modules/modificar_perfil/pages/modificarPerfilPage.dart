import 'dart:io';

import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/providers/cliente_provider/cliente_provider.dart';
import 'package:client_app/src/shared/models/cliente_model.dart';
import 'package:client_app/src/shared/widget/button.dart';
import 'package:client_app/src/shared/widget/input.dart';
import 'package:client_app/src/shared/widget/inputImagem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ModificarPerfilPage extends ConsumerStatefulWidget {
  const ModificarPerfilPage({super.key});

  @override
  ConsumerState<ModificarPerfilPage> createState() =>
      _ModificarPerfilPageState();
}

class _ModificarPerfilPageState extends ConsumerState<ModificarPerfilPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _carregado = false;
  File? _fotoSelecionada;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clienteAsync = ref.watch(clienteProvider);

    if (!_carregado && clienteAsync.hasValue && clienteAsync.value != null) {
      final cliente = clienteAsync.value!;
      nameController.text = cliente.nomeCompleto;
      emailController.text = cliente.email;
      phoneController.text = cliente.telefone;
      _carregado = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modificar perfil"),
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

                InputFotoPerfil(
                  imagemInicialUrl:
                      ApiClient.imagemUrl(clienteAsync.value?.fotoPath),
                  onImagemSelecionada: (arquivo) => _fotoSelecionada = arquivo,
                ),

                const SizedBox(height: 20),

                CustomButton(
                  label: "Salvar",
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

                    if (!_formKey.currentState!.validate()) {
                      aviso("Erro ao salvar alterações", erro: true);
                      return;
                    }

                    try {
                      final clienteAtual = clienteAsync.value;
                      final atualizado = ClienteModel(
                        id: clienteAtual?.id,
                        nomeCompleto: nameController.text.trim(),
                        email: emailController.text.trim(),
                        telefone: phoneController.text.trim(),
                        fotoPath: clienteAtual?.fotoPath,
                      );
                      await ref
                          .read(clienteProvider.notifier)
                          .atualizarPerfil(atualizado);

                      if (_fotoSelecionada != null) {
                        await ref
                            .read(clienteProvider.notifier)
                            .enviarImagemPerfil(_fotoSelecionada!);
                      }

                      aviso("Alterações salvas");
                      router.go('/perfil');
                    } catch (_) {
                      aviso("Erro ao salvar alterações", erro: true);
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
