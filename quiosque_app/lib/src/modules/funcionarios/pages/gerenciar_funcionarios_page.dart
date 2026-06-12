import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiosque_app/providers/funcionarios_provider/funcionarios_provider.dart';
import 'package:quiosque_app/providers/sessao_provider/sessao_provider.dart';

class GerenciarFuncionariosPage extends ConsumerWidget {
  const GerenciarFuncionariosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final funcionariosAsync = ref.watch(funcionariosProvider);
    // Gerente e dono visualizam os dados de login dos funcionários.
    final podeVerLogin = ref.watch(cargoAtualProvider).podeGerenciar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar funcionários'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/cadastroFuncionario'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: funcionariosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Não foi possível carregar os funcionários.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
          ),
          data: (funcionarios) => funcionarios.isEmpty
            ? const Center(child: Text('Nenhum funcionário cadastrado.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: funcionarios.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final f = funcionarios[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => context.push('/editarFuncionario', extra: f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.nomeCompleto,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500)),
                                Text(f.cargo.label,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.7))),
                                if (podeVerLogin && f.usuario.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                        'Login: ${f.usuario}  •  Senha: ${f.senha}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w500)),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_circle_right_outlined,
                              color: theme.colorScheme.outline),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}
