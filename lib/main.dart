import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(
    // ChangeNotifierProvider makes our single AppState available to every
    // screen below it in the widget tree.
    ChangeNotifierProvider(
      create: (_) => AppState()..loadSession(),
      child: const AluConnectApp(),
    ),
  );
}

class AluConnectApp extends StatelessWidget {
  const AluConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      // The auth gate: logged-in users see the app shell, everyone else
      // sees the login/onboarding flow. Because we watch AppState, logging
      // in or out automatically swaps the screen.
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.watch<AppState>().isLoggedIn;
    return loggedIn ? const HomeShell() : const LoginScreen();
  }
}
