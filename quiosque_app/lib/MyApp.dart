import 'package:quiosque_app/src/modules/ajuda/pages/ajudaPage.dart';
import 'package:quiosque_app/src/modules/ajuda/pages/ajudaTopico.dart';
import 'package:quiosque_app/src/modules/cadastro/pages/cadastro.dart';
import 'package:quiosque_app/src/modules/historicoPedidos/pages/historicoPedidosPage.dart';
import 'package:quiosque_app/src/modules/historicoPedidos/pages/historico_detalhe_page.dart';
import 'package:quiosque_app/src/modules/funcionarios/pages/funcionario_form_page.dart';
import 'package:quiosque_app/src/modules/funcionarios/pages/gerenciar_funcionarios_page.dart';
import 'package:quiosque_app/src/modules/login/pages/login.dart';
import 'package:quiosque_app/src/modules/modificar_perfil/pages/modificarPerfilPage.dart';
import 'package:quiosque_app/src/modules/modificar_perfil/pages/alterar_localizacao_page.dart';
import 'package:quiosque_app/src/modules/paginaQuiosque/pages/item_form_page.dart';
import 'package:quiosque_app/src/modules/paginaQuiosque/pages/pagina_quiosque_page.dart';
import 'package:quiosque_app/src/modules/pedidoInterno/pages/cardapio_interno_page.dart';
import 'package:quiosque_app/src/modules/pedidoInterno/pages/carrinho_interno_page.dart';
import 'package:quiosque_app/src/modules/pedidoInterno/pages/item_selecao_page.dart';
import 'package:quiosque_app/src/modules/pedidosQuiosque/pages/cancelar_pedido_page.dart';
import 'package:quiosque_app/src/modules/pedidosQuiosque/pages/pedido_descricao_page.dart';
import 'package:quiosque_app/src/modules/pedidosQuiosque/pages/pedidos_quiosque_page.dart';
import 'package:quiosque_app/src/modules/perfil/pages/perfilPage.dart';
import 'package:quiosque_app/src/shared/models/ajuda_model.dart';
import 'package:quiosque_app/src/shared/models/cardapio_item.dart';
import 'package:quiosque_app/src/shared/models/funcionario.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';
import 'package:quiosque_app/src/shared/models/pedidos_model.dart';
import 'package:quiosque_app/data/services/notification_service.dart';
import 'package:quiosque_app/providers/quiosque_provider/quiosque_provider.dart';
import 'package:quiosque_app/src/shared/widget/CustomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashRedirect(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const Login(),
    ),

    GoRoute(
      path: '/cadastro',
      builder: (context, state) => Cadastro(),
    ),

    GoRoute(
      path: '/modificarPerfil',
      builder: (context, state) => ModificarPerfilPage(),
    ),

    GoRoute(
      path: '/alterarLocalizacao',
      builder: (context, state) => const AlterarLocalizacaoPage(),
    ),

    GoRoute(
      path: '/ajuda',
      builder: (context, state) => AjudaPage(),
    ),

    GoRoute(
      path: '/ajudaTopico',
      builder: (context, state) {
        final ajuda = state.extra as AjudaModel;
        return AjudaTopico(assunto: ajuda);
      },
    ),

    GoRoute(
      path: '/historico',
      builder: (context, state) => HistoricoPedidos(),
    ),

    GoRoute(
      path: '/historicoDetalhe',
      builder: (context, state) {
        final pedido = state.extra as PedidosModel;
        return HistoricoDetalhePage(pedido: pedido);
      },
    ),

    GoRoute(
      path: '/cadastroItem',
      builder: (context, state) {
        final secaoId = state.extra as String;
        return ItemFormPage(secaoId: secaoId);
      },
    ),

    GoRoute(
      path: '/editarItem',
      builder: (context, state) {
        final extra = state.extra as ({String secaoId, CardapioItem item});
        return ItemFormPage(secaoId: extra.secaoId, item: extra.item);
      },
    ),

    GoRoute(
      path: '/gerenciarFuncionarios',
      builder: (context, state) => const GerenciarFuncionariosPage(),
    ),

    GoRoute(
      path: '/cadastroFuncionario',
      builder: (context, state) => const FuncionarioFormPage(),
    ),

    GoRoute(
      path: '/editarFuncionario',
      builder: (context, state) {
        final funcionario = state.extra as Funcionario;
        return FuncionarioFormPage(funcionario: funcionario);
      },
    ),

    GoRoute(
      path: '/pedidoDescricao',
      builder: (context, state) {
        final pedido = state.extra as PedidoRecebido;
        return PedidoDescricaoPage(pedido: pedido);
      },
    ),

    GoRoute(
      path: '/cancelarPedido',
      builder: (context, state) {
        final pedido = state.extra as PedidoRecebido;
        return CancelarPedidoPage(pedido: pedido);
      },
    ),

    GoRoute(
      path: '/cardapioInterno',
      builder: (context, state) => const CardapioInternoPage(),
    ),

    GoRoute(
      path: '/itemSelecao',
      builder: (context, state) {
        final item = state.extra as CardapioItem;
        return ItemSelecaoPage(item: item);
      },
    ),

    GoRoute(
      path: '/itemDescricao',
      builder: (context, state) {
        final item = state.extra as CardapioItem;
        return ItemSelecaoPage(item: item, somenteVisualizacao: true);
      },
    ),

    GoRoute(
      path: '/carrinhoInterno',
      builder: (context, state) => const CarrinhoInternoPage(),
    ),

    //Abas do gestor
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/paginaQuiosque',
                builder: (context, state) => const PaginaQuiosquePage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pedidos',
                builder: (context, state) => const PedidosQuiosquePage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const PerfilPage(),
              ),
            ],
          ),
        ]),
  ],
);

/// Tela inicial que decide o destino conforme o estado de login:
/// se houver um quiosque logado, abre a página do quiosque; caso contrário,
/// abre a tela de login.
class SplashRedirect extends ConsumerWidget {
  const SplashRedirect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiosqueAsync = ref.watch(quiosqueProvider);

    return quiosqueAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/login');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      data: (quiosque) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (quiosque != null) {
            // Sessão restaurada: garante que o back-end tem o token de push
            // atual (FCM) para os pedidos atualizarem sozinhos.
            NotificationService.instance.sincronizarToken();
          }
          context.go(quiosque != null ? '/paginaQuiosque' : '/login');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF3A2E2E);

    return MaterialApp.router(
      routerConfig: _router,
      title: "Pôr-do-Sol",
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffFDE8DA),
          outline: const Color(0xFF3A2E2E),
          surface: const Color(0xFFFFFCF5),
          primary: const Color(0xFFC0420A),
          secondary: const Color(0xFFF5A06A),
          tertiary: const Color(0xFFCB6436),
          onPrimary: const Color(0xffFDE8DA),
          onSecondary: const Color(0xFFF5C4A4),
          onTertiary: Colors.white,
          onSurface: const Color(0xFFFDD06A),
          outlineVariant: const Color(0xFF575757),
          error: const Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: const Color(0xFFFFDAD6),
          onErrorContainer: const Color(0xFF410002),
        ),
        scaffoldBackgroundColor: const Color(0xffFDE8DA),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineLarge: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          titleSmall: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF5C4A4),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC0420A),
          foregroundColor: Color(0xffFDE8DA),
        ),
      ),
    );
  }
}
