import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/password_login_screen.dart';
import 'theme.dart';

class FirdusiApp extends StatelessWidget {
  const FirdusiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return MaterialApp(
      title: appState.restaurantInfo.name.isNotEmpty
          ? appState.restaurantInfo.name
          : 'Firdusi Food',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: appState.isInitialized
          ? const MainShell()
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
      routes: {
        AdminLoginScreen.routeName: (_) => const AdminLoginScreen(),
        AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
        PasswordLoginScreen.routeName: (_) => const PasswordLoginScreen(),
      },
    );
  }
}
