import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Onboarding entry point. Toggles between Login and Sign Up.
/// Everyone who signs up becomes a Student — the foundation of the
/// trust/access model. Demo accounts (see MockData) let graders log straight
/// in as an organizer or admin:
///   admin@alu.edu / kwame@alu.edu / liana@alu.edu  (any non-empty password)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _house = 'Ubuntu';
  String? _error;

  static const _houses = ['Ubuntu', 'Imagine', 'Ngozi', 'Tofik', 'Sankofa'];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final state = context.read<AppState>();
    final err = _isLogin
        ? state.login(_email.text, _password.text)
        : state.signUp(
            name: _name.text,
            email: _email.text,
            house: _house,
            password: _password.text,
          );
    setState(() => _error = err);
    // On success the AuthGate swaps to HomeShell automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text('ALU Connect',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
                        )),
                const SizedBox(height: 6),
                Text(
                  _isLogin
                      ? 'Welcome back.'
                      : 'Join the trusted ALU community feed.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                if (!_isLogin) ...[
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _house,
                    decoration: const InputDecoration(labelText: 'House'),
                    items: _houses
                        .map((h) =>
                            DropdownMenuItem(value: h, child: Text(h)))
                        .toList(),
                    onChanged: (v) => setState(() => _house = v ?? 'Ubuntu'),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submit,
                  child: Text(_isLogin ? 'Log in' : 'Create account'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _isLogin = !_isLogin;
                    _error = null;
                  }),
                  child: Text(_isLogin
                      ? "New here? Create an account"
                      : 'Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
