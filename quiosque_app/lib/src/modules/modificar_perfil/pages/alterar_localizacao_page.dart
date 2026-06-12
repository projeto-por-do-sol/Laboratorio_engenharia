import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/providers/pagina_quiosque_provider/pagina_quiosque_provider.dart';
import 'package:quiosque_app/src/shared/widget/button.dart';
import 'package:quiosque_app/src/shared/widget/input.dart';
import 'package:quiosque_app/src/shared/widget/modais.dart';
import 'package:quiosque_app/src/shared/widget/seletor_localizacao.dart';

/// Página para alterar a localização do quiosque: endereço (CEP, cidade, UF) e
/// um ponto no mapa. Persiste via `PUT /quiosques/me` (atualização parcial).
class AlterarLocalizacaoPage extends ConsumerStatefulWidget {
  const AlterarLocalizacaoPage({super.key});

  @override
  ConsumerState<AlterarLocalizacaoPage> createState() =>
      _AlterarLocalizacaoPageState();
}

class _AlterarLocalizacaoPageState
    extends ConsumerState<AlterarLocalizacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  LatLng? _localizacao;
  bool _processando = false;
  // Pré-carrega apenas uma vez (no primeiro build com dados disponíveis).
  bool _preenchido = false;

  /// Preenche os campos com a localização já cadastrada do quiosque.
  void _preencherSeNecessario() {
    if (_preenchido) return;
    final pagina = ref.read(paginaQuiosqueProvider).value;
    if (pagina == null) return;
    _preenchido = true;
    _cepController.text = pagina.cep ?? '';
    _cidadeController.text = pagina.cidade ?? '';
    _ufController.text = pagina.uf ?? '';
    if (pagina.latitude != null && pagina.longitude != null) {
      _localizacao = LatLng(pagina.latitude!, pagina.longitude!);
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_localizacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione a nova localização no mapa!'.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    setState(() => _processando = true);
    try {
      await ref.read(paginaQuiosqueProvider.notifier).setLocalizacao(
            cep: _cepController.text.trim(),
            cidade: _cidadeController.text.trim(),
            uf: _ufController.text.trim(),
            latitude: _localizacao!.latitude,
            longitude: _localizacao!.longitude,
          );
      if (!mounted) return;
      await mostrarAlerta(context,
          mensagem: 'Localização atualizada!',
          icone: Icons.check_circle_outline);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (mounted) await mostrarAlerta(context, mensagem: e.mensagem);
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o provider para reconstruir quando os dados do quiosque chegarem.
    ref.watch(paginaQuiosqueProvider);
    _preencherSeNecessario();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar localização'),
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
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'CEP:',
                      controller: _cepController,
                      isRequired: true,
                      isCEP: true,
                    ),
                    const SizedBox(height: 15),
                    CustomInput(
                      label: 'Cidade:',
                      controller: _cidadeController,
                      isRequired: true,
                      typeText: TextCapitalization.words,
                    ),
                    const SizedBox(height: 15),
                    CustomInput(
                      label: 'UF:',
                      controller: _ufController,
                      isRequired: true,
                      typeText: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 15),
                    SeletorLocalizacao(
                      valor: _localizacao,
                      label: 'Nova localização do quiosque:',
                      onChanged: (ponto) =>
                          setState(() => _localizacao = ponto),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(label: 'Salvar', onPressed: _salvar),
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
