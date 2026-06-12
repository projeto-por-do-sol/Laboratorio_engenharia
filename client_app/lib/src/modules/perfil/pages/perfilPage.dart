import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/providers/cliente_provider/cliente_provider.dart';
import 'package:client_app/src/shared/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PerfilPage extends ConsumerWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clienteProvider);
    final cliente = clienteAsync.value;
    final estaLogado = cliente != null;

    Widget imagemPerfil() {
      const tamanhoImagem = 70.0;
      final fotoUrl = ApiClient.imagemUrl(cliente?.fotoPath);

      Widget placeholder() => Container(
            height: tamanhoImagem,
            width: tamanhoImagem,
            color: Colors.grey[300],
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.outline,
              size: 40,
            ),
          );

      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: fotoUrl == null
            ? placeholder()
            : Image.network(
                fotoUrl,
                height: tamanhoImagem,
                width: tamanhoImagem,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => placeholder(),
              ),
      );
    }

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
                            ref.read(clienteProvider.notifier).logout();
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

                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.pop(ctx);
                            try {
                              await ref
                                  .read(clienteProvider.notifier)
                                  .deletarConta();
                            } catch (_) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Não foi possível excluir a conta. Tente novamente.'),
                                ),
                              );
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

    final List<List<dynamic>> listaTopicosLogado = [
      ['Modificar perfil', '/modificarPerfil', Icons.info_outline, null],
      ['Histórico de pedidos', '/historicoPedidos', Icons.history_outlined, null],
      ['Ajuda', '/ajuda', Icons.help_outline, null],
      ['Sair', null, Icons.logout_outlined, confirmarLogout],
      ['Excluir conta', null, Icons.delete_forever_outlined, confirmarExcluirConta],
    ];

    final List<List<dynamic>> listaTopicosDeslogado = [
      ['Entrar', '/login', Icons.login_outlined, null],
      ['Cadastrar-se', '/cadastro', Icons.person_add_outlined, null],
      ['Ajuda', '/ajuda', Icons.help_outline, null],
    ];

    final listaTopicos = estaLogado ? listaTopicosLogado : listaTopicosDeslogado;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: imagemPerfil(),
                ),

                Text(
                  estaLogado
                      ? cliente.nomeCompleto.split(' ').first
                      : 'Visitante',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 15),

          ...listaTopicos.map(
            (topico) => Column(
              children: [
                CustomButton(
                  label: topico[0],
                  icone: topico[2],
                  onPressed: topico[3] != null
                      ? topico[3] as VoidCallback
                      : () => context.push(topico[1] as String),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
