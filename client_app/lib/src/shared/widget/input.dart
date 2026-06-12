import 'package:client_app/src/shared/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isEmail;
  final bool isPhone;
  final bool isPhoneOrEmail;
  final bool isRequired;
  final bool isCPF;
  final TextCapitalization typeText;

  const CustomInput({
    super.key,
    required this.label,
    this.isPassword = false,
    this.controller,
    this.isEmail = false,
    this.isPhone = false,
    this.isPhoneOrEmail = false,
    this.isRequired = true,
    this.isCPF = false,
    this.typeText = TextCapitalization.none,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  //Pegar valor sem mascara maskCpf.getUnmaskedText()

  var maskCpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  var maskPhone = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: { "#": RegExp(r'[0-9]') }
  );

  late bool _obscureText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(child: Container()),
              Text(
                widget.isRequired ? '*' : '',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          TextFormField(
            focusNode: _focusNode,
            keyboardType: widget.isEmail || widget.isPhoneOrEmail ? TextInputType.emailAddress : TextInputType.text,
            controller: widget.controller,
            obscureText: _obscureText && widget.isPassword,
            autocorrect: false,
            textCapitalization: widget.typeText,
            inputFormatters: widget.isCPF ? [maskCpf] : widget.isPhone ? [maskPhone] : [],

            validator: (value) {
              if (widget.isRequired && (value == null || value.isEmpty)) {
                return 'Este campo é obrigatório';
              }

              if (value == null || value.isEmpty) return null;

              final valorLimpo = value.trim();

              if (widget.isCPF && !cpfValidator.isValidCpf(valorLimpo)) {
                return 'CPF inválido';
              }

              if (widget.isPhone && !phoneValidator.phoneValidate(valorLimpo)) {
                return 'Telefone inválido (use DDD + número)';
              }

              if (widget.isEmail && !emailValidator.emailValidate(valorLimpo)) {
                return 'Insira um e-mail válido';
              }

              if (widget.isPhoneOrEmail &&
                  !phoneEmailValidator.phoneEmailValidate(valorLimpo)) {
                  return 'Insira um e-mail ou telefone válido';
              }

              return null;
            },

            decoration: InputDecoration(
              suffixIcon: !widget.isPassword ? null : InkWell(
                onTap: () {
                  _obscureText = !_obscureText;
                  setState(() {});
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: _focusNode.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                ),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2.0,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3.0,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2.0,
                ),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 3.0,
                ),
              ),

              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,

            ),
          ),
        ],
      ),
    );
  }
}