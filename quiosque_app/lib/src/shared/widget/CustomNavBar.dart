import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:quiosque_app/providers/pagina_quiosque_provider/pagina_quiosque_provider.dart';

class CustomNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const CustomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        unselectedItemColor: Theme.of(context).colorScheme.outline,
        currentIndex: currentIndex,
        onTap: (index) {
          // Ao sair da aba do quiosque (índice 0), encerra o modo de edição.
          if (index != 0) {
            ref.read(editandoQuiosqueProvider.notifier).definir(false);
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == currentIndex,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Symbols.home_rounded,
                fill: currentIndex == 0 ? 1 : 0, weight: 700),
            label: "Quiosque",
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.receipt_long_rounded,
                fill: currentIndex == 1 ? 1 : 0, weight: 700),
            label: "Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.person,
                fill: currentIndex == 2 ? 1 : 0, weight: 700),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
