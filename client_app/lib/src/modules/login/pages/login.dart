import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/providers/cliente_provider/cliente_provider.dart';
import 'package:client_app/src/shared/widget/button.dart';
import 'package:client_app/src/shared/widget/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  TextEditingController loginController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('ENTRAR'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                Image.asset('assets/images/logo.png', width: 180),

                const SizedBox(height: 30),

                CustomInput(
                  label: "E-mail:",
                  controller: loginController,
                  isRequired: true,
                  isPhoneOrEmail: true,
                ),

                const SizedBox(height: 30),

                CustomInput(
                  label: "Senha:",
                  controller: passwordController,
                  isRequired: true,
                  isPassword: true,
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    context.push('/cadastro');
                  },
                  child: Text(
                    "Cadastrar-se",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: CustomButton(
                    label: "ENTRAR",
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      FocusManager.instance.primaryFocus?.unfocus();
                      final messenger = ScaffoldMessenger.of(context);
                      final router = GoRouter.of(context);

                      void erro(String msg) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              msg.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }

                      try {
                        await ref.read(clienteProvider.notifier).login(
                              login: loginController.text.trim(),
                              senha: passwordController.text.trim(),
                            );
                        router.go('/inicio');
                      } on ApiException catch (e) {
                        erro(e.statusCode == 401 || e.statusCode == 403
                            ? "E-mail ou senha incorreto(a)!"
                            : "Erro ao entrar. Tente novamente.");
                      } catch (e) {
                        debugPrint('[Login] falha de conexão: $e');
                        erro("Não foi possível conectar ao servidor.");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
