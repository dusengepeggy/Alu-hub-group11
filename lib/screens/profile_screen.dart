import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/user.dart';
import '../data/skill_options.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_card.dart';
import 'admin_panel_screen.dart';
import 'find_teammates_screen.dart';
import 'saved_opportunities_screen.dart';
import 'welcome_screen.dart';

/// Profile / identity screen: header card with stats, then About / RSVPs /
/// Skills tabs. Students can request organizer access; admins reach the panel.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _requestDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Request organizer access'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Why should you be able to post? (e.g. your club role)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final err = dialogCtx
                  .read<AppState>()
                  .submitOrganizerRequest(controller.text);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(err ?? 'Request submitted!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    // No user (e.g. during logout, before AuthGate swaps screens): prompt to
    // sign in rather than force-unwrapping (which would throw).
    if (user == null) return const _LoggedOutPrompt();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: state.logout,
              tooltip: 'Sign out',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(user: user, state: state),
            const SizedBox(height: 16),
            const TabBar(
              tabs: [
                Tab(text: 'About'),
                Tab(text: 'RSVPs'),
                Tab(text: 'Skills'),
              ],
            ),
            // Tabs inside a ListView need a bounded height.
            SizedBox(
              height: 460,
              child: TabBarView(
                children: [
                  _AboutTab(
                    user: user,
                    state: state,
                    onRequest: () => _requestDialog(context),
                  ),
                  _RsvpsTab(state: state),
                  _SkillsTab(user: user, state: state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final User user;
  final AppState state;
  const _HeaderCard({required this.user, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navySurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                      color: AppTheme.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      user.campus.isNotEmpty ? user.campus : user.house,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textMuted),
                    ),
                    Text(user.role.label,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.gold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(value: '${state.myEvents.length}', label: 'RSVPs'),
              _Stat(value: '${state.otherUsers.length}', label: 'Network'),
              _Stat(value: '${user.skills.length}', label: 'Skills'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  final User user;
  final AppState state;
  final VoidCallback onRequest;
  const _AboutTab({
    required this.user,
    required this.state,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      children: [
        if (user.bio.isNotEmpty) ...[
          const Text('Bio', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(user.bio, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 16),
        ],
        if (user.seekingRoles.isNotEmpty) ...[
          const Text('Looking for teammates in',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in user.seekingRoles) Chip(label: Text(r)),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _LinkTile(
          icon: Icons.event_available_outlined,
          title: 'My RSVPs',
          subtitle: '${state.myEvents.length} events & opportunities',
          onTap: () => DefaultTabController.of(context).animateTo(1),
        ),
        _LinkTile(
          icon: Icons.group_outlined,
          title: 'Find Teammates',
          subtitle: 'Skill-based matching',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FindTeammatesScreen()),
          ),
        ),
        _LinkTile(
          icon: Icons.bookmark_border,
          title: 'Saved Opportunities',
          subtitle: '${state.savedOpportunities.length} bookmarked',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const SavedOpportunitiesScreen()),
          ),
        ),
        if (user.role == UserRole.admin)
          _LinkTile(
            icon: Icons.shield_outlined,
            title: 'Admin Panel',
            subtitle: 'Requests & moderation',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
            ),
          ),
        const SizedBox(height: 8),
        if (user.role == UserRole.student)
          state.currentUserHasPendingRequest()
              ? const Chip(label: Text('Organizer request pending'))
              : OutlinedButton.icon(
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Request organizer access'),
                  onPressed: onRequest,
                ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          label: const Text('Sign Out',
              style: TextStyle(color: Colors.redAccent)),
          onPressed: state.logout,
        ),
      ],
    );
  }
}

class _RsvpsTab extends StatelessWidget {
  final AppState state;
  const _RsvpsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final events = state.myEvents;
    if (events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text("You haven't RSVP'd to anything yet.",
              style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      children: [
        for (final o in events) OpportunityCard(opportunity: o),
      ],
    );
  }
}

class _SkillsTab extends StatelessWidget {
  final User user;
  final AppState state;
  const _SkillsTab({required this.user, required this.state});

  void _addSkill(BuildContext context) {
    final remaining = SkillOptions.skills
        .where((s) => !user.skills.contains(s))
        .toList();
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Add a skill',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (remaining.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('You already added every skill.'),
              ),
            for (final s in remaining)
              ListTile(
                title: Text(s),
                onTap: () {
                  sheetCtx.read<AppState>().updateSkills([...user.skills, s]);
                  Navigator.pop(sheetCtx);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      children: [
        const Text('Your Skills',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in user.skills)
              Chip(
                label: Text(s),
                onDeleted: () => state.updateSkills(
                    user.skills.where((x) => x != s).toList()),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Add skill'),
              onPressed: () => _addSkill(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.gold),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}

/// Shown when no user is logged in — prompts them to sign in. AuthGate
/// normally handles routing, but this keeps the profile tab graceful during
/// the logout transition (and as a safety net).
class _LoggedOutPrompt extends StatelessWidget {
  const _LoggedOutPrompt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle_outlined, size: 64),
            const SizedBox(height: 12),
            const Text(
              "You're not signed in.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Sign in to view your profile.'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
