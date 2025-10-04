import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/app_state.dart';

void main() {
  final appState = AppState();
  runApp(AppBootstrap(appState: appState));
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState..initialize(),
      child: const FirdusiApp(),
    );
  }
}
