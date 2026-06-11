import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../data/skill_options.dart';
import 'onboarding_skills_screen.dart';

/// Create-account form. Collects name, ALU email, password and campus, then
/// hands off to the skills onboarding step before entering the app.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? _campus;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _next() {
    final error = context.read<AppState>().signUp(
          name: nameController.text,
          email: emailController.text,
          campus: _campus ?? '',
          password: passwordController.text,
        );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    // Account created + logged in. Continue to skills onboarding.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingSkillsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join the ALU opportunity network',
                  style: TextStyle(color: Color(0xFF9AA8BC)),
                ),
                const SizedBox(height: 24),
                const _Label('Full Name'),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(hintText: 'e.g. Aliné Umuhoza'),
                ),
                const SizedBox(height: 16),
                const _Label('ALU Email'),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'student@alustudent.com',
                  ),
                ),
                const SizedBox(height: 16),
                const _Label('Password'),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: '••••••••'),
                ),
                const SizedBox(height: 16),
                const _Label('Campus'),
                DropdownButtonFormField<String>(
                  initialValue: _campus,
                  isExpanded: true,
                  hint: const Text('Select your campus'),
                  items: [
                    for (final c in SkillOptions.campuses)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => setState(() => _campus = v),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _next,
                  child: const Text('Next →'),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Already have an account? Sign In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
