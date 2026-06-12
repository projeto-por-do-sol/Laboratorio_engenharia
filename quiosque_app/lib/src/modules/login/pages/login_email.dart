import 'package:quiosque_app/src/shared/widget/button.dart';
import 'package:quiosque_app/src/shared/widget/input.dart';
import 'package:flutter/material.dart';

class LoginEmail extends StatefulWidget {
  const LoginEmail({super.key});

  @override
  State<LoginEmail> createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  TextEditingController loginController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(50),
                  child: Text("ENTRAR", style: Theme.of(context).textTheme.headlineLarge),
                ),

                Image.asset('assets/images/logo.png', width: 200),

                const SizedBox(height: 60),

                CustomInput(
                  label: "E-mail / Telefone:",
                  controller: loginController,
                  isRequired: true,
                  isPhoneOrEmail: true,
                ),

                const SizedBox(height: 10),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: CustomButton(
                    label: "PRÓXIMO",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        debugPrint("Formulário válido!");
                        debugPrint("E-mail: ${loginController.text}");
                      } else {
                        debugPrint("Formulário inválido.");
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