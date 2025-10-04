import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final destinations = [
      const NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Меню'),
      NavigationDestination(
        icon: Stack(
          children: [
            const Icon(Icons.shopping_bag_outlined),
            if (appState.cart.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    appState.cart.length.toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        label: 'Корзина',
      ),
      const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Профиль'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), CartScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: destinations,
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
