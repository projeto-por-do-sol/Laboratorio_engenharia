import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/data/api/auth_api.dart';
import 'package:quiosque_app/data/api/quiosque_api.dart';
import 'package:quiosque_app/data/services/notification_service.dart';
import 'package:quiosque_app/data/services/quiosque_service.dart';
import 'package:quiosque_app/providers/quiosque_provider/quiosque_provider.dart';
import 'package:quiosque_app/providers/sessao_provider/sessao_provider.dart';
import 'package:quiosque_app/src/shared/widget/button.dart';
import 'package:quiosque_app/src/shared/widget/input.dart';
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
  bool _carregando = false;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Autentica contra a API: `POST /auth/login` para obter o token e `GET /me`
  /// para carregar o usuário. Em seguida estabelece a sessão e semeia o
  /// quiosque local para que as telas atuais continuem funcionando.
  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _carregando = true);
    try {
      final email = loginController.text.trim();
      final token = await AuthApi.instance.login(
        email: email,
        senha: passwordController.text.trim(),
      );
      // Salva o token antes de chamar /me (o ApiClient o injeta no header).
      await QuiosqueService.instance.salvarJWT(token);

      final usuario = await AuthApi.instance.me();
      ref.read(usuarioAtualProvider.notifier).definir(usuario);

      // Busca o nome real do quiosque (FUNCIONARIO). Se o usuário não tiver
      // acesso a /quiosques/me, mantém o nome do usuário como fallback.
      String nomeQuiosque = usuario.nome;
      try {
        nomeQuiosque = (await QuiosqueApi.instance.buscarMeu()).nome;
      } on ApiException {
        // sem quiosque vinculado / sem permissão — segue com o fallback
      }

      await ref.read(quiosqueProvider.notifier).login(
            nomeQuiosque: nomeQuiosque,
            email: usuario.email,
            telefone: usuario.telefone ?? '',
            token: token,
          );

      // Registra o token de push (FCM) para os pedidos atualizarem sozinhos.
      // Em segundo plano: falhas não atrapalham o login.
      NotificationService.instance.sincronizarToken();

      if (mounted) context.go('/paginaQuiosque');
    } on ApiException catch (e) {
      if (mounted) _mostrarErro(e.mensagem);
    } catch (_) {
      if (mounted) _mostrarErro('Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
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
        body: SafeArea(
          child: SingleChildScrollView(
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
                  child: _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          label: "ENTRAR",
                          onPressed: _entrar,
                        ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
