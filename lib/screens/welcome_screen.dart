import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// First screen for logged-out users: ALU Hub branding with paths to sign up
/// ("Get Started") or log in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Logo mark — gold rounded square with an "A".
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'A',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ALU Hub',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Discover opportunities. Build teams.\nConnect across ALU campuses.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              const _TypeIconStrip(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small decorative row of category icons (mirrors the inspiration).
class _TypeIconStrip extends StatelessWidget {
  const _TypeIconStrip();

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.rocket_launch_outlined,
      Icons.favorite_border,
      Icons.work_outline,
      Icons.celebration_outlined,
    ];
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final i in icons)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.navyElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(i, size: 20, color: AppTheme.textMuted),
            ),
        ],
      ),
    );
  }
}
