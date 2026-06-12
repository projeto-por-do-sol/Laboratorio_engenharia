import 'package:client_app/src/modules/ajuda/pages/ajudaPage.dart';
import 'package:client_app/src/modules/ajuda/pages/ajudaTopico.dart';
import 'package:client_app/src/modules/cadastro/pages/cadastro.dart';
import 'package:client_app/src/modules/carrinho/pages/carrinho.dart';
import 'package:client_app/src/modules/historicoPedidos/pages/avaliar_pedidos.dart';
import 'package:client_app/src/modules/historicoPedidos/pages/historicoPedidosPage.dart';
import 'package:client_app/src/modules/inicio/pages/inicio.dart';
import 'package:client_app/src/modules/itemPage/pages/itemPage.dart';
import 'package:client_app/src/modules/login/pages/login.dart';
import 'package:client_app/src/modules/modificar_perfil/pages/modificarPerfilPage.dart';
import 'package:client_app/src/modules/pedidos/pages/pedidos.dart';
import 'package:client_app/src/modules/perfil/pages/perfilPage.dart';
import 'package:client_app/src/modules/quiosquePage/pages/quiosquePage.dart';
import 'package:client_app/src/shared/models/ajuda_model.dart';
import 'package:client_app/src/shared/models/item_carrinho.dart';
import 'package:client_app/src/shared/models/item_quiosque.dart';
import 'package:client_app/src/shared/models/pedidos_model.dart';
import 'package:client_app/src/shared/models/quiosque_model.dart';
import 'package:client_app/src/shared/widget/CustomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/inicio',
  routes: <RouteBase>[
    //Colocar as páginas que não terão na navBar
    GoRoute(
      path: '/login',
      builder: (context, state) => const Login(),
    ),

    GoRoute(
      path: '/cadastro',
      builder: (context, state) => Cadastro(),
    ),

    GoRoute(
      path: '/quiosquePage',
      builder: (context, state) {
        final quiosque = state.extra as QuiosqueModel;
        return QuiosquePage(quiosque: quiosque);
      },
    ),

    GoRoute(
      path: '/modificarPerfil',
      builder: (context, state) => ModificarPerfilPage(),
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
      path: '/historicoPedidos',
      builder: (context, state) => HistoricoPedidos(),
    ),

    GoRoute(
      path: '/avaliarPedidos',
      builder: (context, state) {
        final pedido = state.extra as PedidosModel;
        return AvaliarPedidos(pedido: pedido);
      },
    ),

    GoRoute(
      path: '/itemPage',
      builder: (context, state) {
        final extra = state.extra as ({ItemQuiosque item, QuiosqueCarrinho quiosque, bool desabilitado});
        return ItemPage(item: extra.item, quiosque: extra.quiosque, desabilitado: extra.desabilitado);
      },
    ),

    //Links do navBar
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell){
          return CustomNavBar(navigationShell: navigationShell);
        },
        branches:[
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inicio',
                builder: (context, state) => HomePage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/carrinho',
                builder: (context, state) => CarrinhoPage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pedidos',
                builder: (context, state) => PedidosPage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => PerfilPage(),
              ),
            ],
          ),

        ]
    ),
  ]
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF3A2E2E);
    // const borderColor = Color(0xFF1D3557);

    return MaterialApp.router(
      routerConfig: appRouter,
      title: "Pôr-do-Sol",
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,

        // seedColor: const Color(0xFFFFF5DD),
        // outline: const Color(0xFF3A2E2E),
        // surface: const Color(0xFFFFFCF5),
        // primary: const Color(0xFFBD6100),
        // secondary: const Color(0xFFEFEFEF),

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

        // scaffoldBackgroundColor: const Color(0xFFFFF5DD),
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

        // ).apply(
        //   bodyColor: textColor,
        //   displayColor: textColor,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC0420A),
          foregroundColor: Color(0xffFDE8DA),
        ),
      ),
      // home: const HomePage(),
    );
  }
}
