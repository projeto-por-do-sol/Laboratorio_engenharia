import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/data/api/auth_api.dart';
import 'package:quiosque_app/providers/quiosque_provider/quiosque_provider.dart';
import 'package:quiosque_app/providers/sessao_provider/sessao_provider.dart';
import 'package:quiosque_app/src/shared/widget/button.dart';
import 'package:quiosque_app/src/shared/widget/input.dart';
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiosqueAsync = ref.watch(quiosqueProvider);
    final usuario = ref.watch(usuarioAtualProvider);

    if (!_carregado) {
      final quiosque = quiosqueAsync.value;
      nameController.text = usuario?.nome ?? quiosque?.nomeQuiosque ?? '';
      emailController.text = usuario?.email ?? quiosque?.email ?? '';
      phoneController.text = usuario?.telefone ?? quiosque?.telefone ?? '';
      if (usuario != null || quiosque != null) _carregado = true;
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
                  label: "Nome do Quiosque:",
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

                const SizedBox(height: 20),

                CustomButton(
                  label: "Salvar",
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    void mensagem(String texto, Color cor) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            texto.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: cor,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }

                    try {
                      // PUT /me — atualiza o perfil do usuário autenticado.
                      final atualizado =
                          await AuthApi.instance.atualizarPerfil(
                        nome: nameController.text.trim(),
                        email: emailController.text.trim(),
                        telefone: phoneController.text.trim(),
                      );
                      ref
                          .read(usuarioAtualProvider.notifier)
                          .definir(atualizado);

                      // Mantém o quiosque local em sincronia (cabeçalho do perfil).
                      final q = ref.read(quiosqueProvider).value;
                      if (q != null) {
                        await ref
                            .read(quiosqueProvider.notifier)
                            .atualizarPerfil(q.copyWith(
                              nomeQuiosque: nameController.text.trim(),
                              email: emailController.text.trim(),
                              telefone: phoneController.text.trim(),
                            ));
                      }

                      if (context.mounted) {
                        mensagem('Alterações salvas',
                            Theme.of(context).colorScheme.primary);
                        context.go('/perfil');
                      }
                    } on ApiException catch (e) {
                      if (context.mounted) {
                        mensagem(e.mensagem,
                            Theme.of(context).colorScheme.error);
                      }
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
