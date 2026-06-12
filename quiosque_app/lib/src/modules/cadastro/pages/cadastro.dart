import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/providers/quiosque_provider/quiosque_provider.dart';
import 'package:quiosque_app/src/shared/widget/button.dart';
import 'package:quiosque_app/src/shared/widget/input.dart';
import 'package:quiosque_app/src/shared/widget/modais.dart';
import 'package:quiosque_app/src/shared/widget/seletor_localizacao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class Cadastro extends ConsumerStatefulWidget {
  const Cadastro({super.key});

  @override
  ConsumerState<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends ConsumerState<Cadastro> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cnpjController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  TextEditingController cepController = TextEditingController();
  TextEditingController cidadeController = TextEditingController();
  TextEditingController ufController = TextEditingController();
  LatLng? _localizacao;
  bool _processando = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cnpjController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    cepController.dispose();
    cidadeController.dispose();
    ufController.dispose();
    super.dispose();
  }

  void _avisar(String mensagem) {
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

  Future<void> _criarConta() async {
    if (passwordController.text != passwordConfirmController.text) {
      _avisar('As senhas não coincidem!');
      return;
    }
    if (_localizacao == null) {
      _avisar('Selecione a localização do quiosque no mapa!');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processando = true);
    try {
      await ref.read(quiosqueProvider.notifier).cadastrar(
            nomeQuiosque: nameController.text.trim(),
            email: emailController.text.trim(),
            telefone: phoneController.text.trim(),
            cnpj: cnpjController.text.trim(),
            senha: passwordController.text.trim(),
            cep: cepController.text.trim(),
            cidade: cidadeController.text.trim(),
            uf: ufController.text.trim(),
            latitude: _localizacao!.latitude,
            longitude: _localizacao!.longitude,
          );
      if (mounted) context.go('/paginaQuiosque');
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    } catch (_) {
      if (mounted) {
        await mostrarAlerta(context,
            mensagem: 'Não foi possível criar a conta. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
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
                    const SizedBox(height: 15),
                    CustomInput(
                      label: "CNPJ:",
                      controller: cnpjController,
                      isRequired: true,
                      isCNPJ: true,
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
                    CustomInput(
                      label: "CEP:",
                      controller: cepController,
                      isRequired: true,
                      isCEP: true,
                    ),
                    const SizedBox(height: 15),
                    CustomInput(
                      label: "Cidade:",
                      controller: cidadeController,
                      isRequired: true,
                      typeText: TextCapitalization.words,
                    ),
                    const SizedBox(height: 15),
                    CustomInput(
                      label: "UF:",
                      controller: ufController,
                      isRequired: true,
                      typeText: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 15),
                    SeletorLocalizacao(
                      valor: _localizacao,
                      onChanged: (ponto) =>
                          setState(() => _localizacao = ponto),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: "criar conta",
                      onPressed: _criarConta,
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
}
