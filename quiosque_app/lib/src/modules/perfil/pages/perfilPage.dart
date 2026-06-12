import 'package:quiosque_app/src/shared/utils/imagem_remota.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/providers/pagina_quiosque_provider/pagina_quiosque_provider.dart';
import 'package:quiosque_app/providers/quiosque_provider/quiosque_provider.dart';
import 'package:quiosque_app/providers/sessao_provider/sessao_provider.dart';
import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/src/shared/models/funcionario.dart';
import 'package:quiosque_app/src/shared/widget/button.dart';

class PerfilPage extends ConsumerWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quiosque = ref.watch(quiosqueProvider).value;
    final cargo = ref.watch(cargoAtualProvider);
    final bannerPath = ref.watch(paginaQuiosqueProvider).value?.capaPath;
    final nome = quiosque?.nomeQuiosque ?? 'Nome quiosque/funcionário';
    final ehDono = cargo == Cargo.dono;

    // Future<void> sair() async {
    //   final ok = await mostrarModalConfirmacao(context,
    //       pergunta: 'Deseja sair da conta?', icone: Icons.logout);
    //   if (ok == true) {
    //     await ref.read(quiosqueProvider.notifier).logout();
    //     if (context.mounted) context.go('/login');
    //   }
    // }
    //
    // Future<void> excluirConta() async {
    //   final continuar = await mostrarModalConfirmacao(context,
    //       pergunta: 'Excluir conta? A conta será excluída.',
    //       icone: Icons.info_outline,
    //       textoNegar: 'Cancelar',
    //       textoConfirmar: 'Continuar');
    //   if (continuar != true || !context.mounted) return;
    //
    //   final confirmar = await mostrarModalConfirmacao(context,
    //       pergunta: 'Deseja realmente excluir sua conta?',
    //       icone: Icons.info_outline);
    //   if (confirmar == true) {
    //     await ref.read(quiosqueProvider.notifier).deletarConta();
    //     if (context.mounted) context.go('/login');
    //   }
    // }

    void confirmarLogout() {
      showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.surface,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 15,
                        child: Icon(
                          Icons.logout_outlined,
                          size: 26,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Text(
                          'deseja sair da conta?'.toUpperCase(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onTertiary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          label: const Text('NÃO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.outline,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          label: const Text('SIM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref.read(quiosqueProvider.notifier).logout();
                            if (context.mounted) context.go('/login');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    void confirmarExcluirConta() {
      showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.surface,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 15,
                        child: Icon(
                          Icons.delete_forever_outlined,
                          size: 26,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Text(
                          'deseja excluir sua conta?'.toUpperCase(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onTertiary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          label: const Text('NÃO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.outline,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          label: const Text('SIM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            try {
                              await ref.read(quiosqueProvider.notifier).deletarConta();
                              if (context.mounted) context.go('/login');
                            } on ApiException catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.mensagem.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final opcoes = <(String, IconData, VoidCallback)>[
      // Apenas o dono pode modificar o perfil da conta do quiosque.
      if (ehDono)
        ('Modificar perfil', Icons.info_outline, () => context.push('/modificarPerfil')),
      // Dono/gerente podem alterar a localização do quiosque.
      if (cargo.podeGerenciar)
        ('Alterar localização', Icons.location_on_outlined, () => context.push('/alterarLocalizacao')),
      // Apenas dono/gerente gerenciam funcionários (funcionário comum não).
      if (cargo.podeGerenciar)
        ('Gerenciar funcionários', Icons.people_outline, () => context.push('/gerenciarFuncionarios')),
      ('Histórico de pedidos', Icons.history, () => context.push('/historico')),
      ('Ajuda', Icons.help_outline, () => context.push('/ajuda')),
      ('Sair', Icons.logout, confirmarLogout),
      // Apenas o dono pode excluir a conta (funcionários/gerentes não podem).
      if (ehDono)
        ('Excluir conta', Icons.delete_outline, confirmarExcluirConta),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Banner do quiosque no lugar da foto de perfil.
                    SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: provedorImagem(bannerPath) != null
                          ? Image(
                              image: provedorImagem(bannerPath)!,
                              fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[350],
                              child: Icon(Icons.storefront,
                                  size: 48, color: theme.colorScheme.outline),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      child: Text(
                        nome,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...opcoes.map(
                (o) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomButton(label: o.$1, icone: o.$2, onPressed: o.$3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
