import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../data/skill_options.dart';
import '../theme/app_theme.dart';

/// Post-signup onboarding: the new user picks their skills so we can match
/// them with the right opportunities and teammates. Saving lands them in the
/// app (AuthGate already shows HomeShell since they're logged in).
class OnboardingSkillsScreen extends StatefulWidget {
  const OnboardingSkillsScreen({super.key});

  @override
  State<OnboardingSkillsScreen> createState() => _OnboardingSkillsScreenState();
}

class _OnboardingSkillsScreenState extends State<OnboardingSkillsScreen> {
  final Set<String> _selected = {};

  void _finish() {
    context.read<AppState>().updateSkills(_selected.toList());
    // Pop back to the AuthGate root — now showing HomeShell.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar (final onboarding step).
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 5,
                  backgroundColor: AppTheme.navyElevated,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your skills ✨',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select skills so we can match you with the right '
                'opportunities and teammates.',
                style: TextStyle(color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final skill in SkillOptions.skills)
                        FilterChip(
                          label: Text(skill),
                          selected: _selected.contains(skill),
                          onSelected: (on) {
                            setState(() {
                              if (on) {
                                _selected.add(skill);
                              } else {
                                _selected.remove(skill);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _finish,
                  child: const Text("Let's Go 🚀"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
