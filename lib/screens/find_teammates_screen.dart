import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

/// Skill-based teammate matching: lists other users who are open to teammates
/// or share a skill with the current user.
class FindTeammatesScreen extends StatelessWidget {
  const FindTeammatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final me = state.currentUser;
    final teammates = state.findTeammates();
    final mySkills = me?.skills.map((s) => s.toLowerCase()).toSet() ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Find Teammates')),
      body: teammates.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group_outlined,
                        size: 56, color: AppTheme.textMuted),
                    SizedBox(height: 12),
                    Text('No matches yet.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Add more skills to your profile to find teammates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final u in teammates)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.gold,
                            child: Text(u.initials,
                                style: const TextStyle(
                                    color: AppTheme.navy,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  '${u.campus.isNotEmpty ? u.campus : u.house} · ${u.role.label}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted),
                                ),
                                if (u.skills.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final s in u.skills)
                                        _SkillChip(
                                          label: s,
                                          shared: mySkills
                                              .contains(s.toLowerCase()),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final bool shared;
  const _SkillChip({required this.label, required this.shared});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: shared
            ? AppTheme.gold.withValues(alpha: 0.18)
            : AppTheme.navyElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: shared ? AppTheme.gold : AppTheme.textLight,
          fontWeight: shared ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
