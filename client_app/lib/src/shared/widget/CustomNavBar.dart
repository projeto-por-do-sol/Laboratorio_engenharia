import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CustomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const CustomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        unselectedItemColor: Theme.of(context).colorScheme.outline,

          currentIndex: currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == currentIndex,
          ),
        items: [
          BottomNavigationBarItem(icon:
          Icon(
            Symbols.home_rounded,
            fill: currentIndex == 0 ? 1 : 0,
            weight: 700,
          ),
            label: "Início"
          ),

          BottomNavigationBarItem(icon:
          Icon(
            Symbols.shopping_cart_rounded,
            fill: currentIndex == 1 ? 1 : 0,
            weight: 700,
          ),
              label: "Carrinho"
          ),

          BottomNavigationBarItem(icon:
          Icon(
            Symbols.receipt_rounded,
            fill: currentIndex == 2 ? 1 : 0,
            weight: 700,
          ),
              label: "Pedidos"
          ),

          BottomNavigationBarItem(icon:
          Icon(
            Symbols.person,
            fill: currentIndex == 3 ? 1 : 0,
            weight: 700,
          ),
              label: "Perfil"
          ),
        ],
      ),
    );
  }
}

