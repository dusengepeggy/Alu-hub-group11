import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/user.dart';
import '../data/skill_options.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_cards.dart';
import '../widgets/opportunity_meta.dart';
import '../widgets/screen_header.dart';
import 'find_teammates_screen.dart';
import 'saved_opportunities_screen.dart';
import 'opportunity_detail_screen.dart';
import 'welcome_screen.dart';

/// Profile screen: identity card + stats, an About/RSVPs/Skills toggle, an
/// edit mode and account settings. Backed entirely by real [AppState] data.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 0 = About, 1 = RSVPs, 2 = Skills
  int _activeToggleIndex = 0;

  // 'view' | 'edit' | 'settings'
  String _viewMode = 'view';

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _openEdit(User user) {
    _nameController.text = user.name;
    _locationController.text = user.campus;
    _bioController.text = user.bio;
    setState(() => _viewMode = 'edit');
  }

  void _save(AppState state) {
    state.updateProfile(
      name: _nameController.text,
      bio: _bioController.text,
      campus: _locationController.text,
    );
    setState(() => _viewMode = 'view');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    if (user == null) return const _LoggedOutPrompt();

    final Widget body;
    if (_viewMode == 'settings') {
      body = _buildSettingsPanel();
    } else if (_viewMode == 'edit') {
      body = _buildEditPanel(state);
    } else {
      body = _buildViewPanel(state, user);
    }

    return Scaffold(body: SafeArea(child: body));
  }

  // ── Settings ───────────────────────────────────────
  Widget _buildSettingsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenHeader(
          title: 'Settings',
          onBack: () => setState(() => _viewMode = 'view'),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ActionMenuRow(
                  icon: Icons.lock_outline,
                  iconColor: AppTheme.textMuted,
                  title: 'Account Privacy',
                  subtitle: 'Manage visibility details',
                ),
                ActionMenuRow(
                  icon: Icons.notifications_none,
                  iconColor: AppTheme.textMuted,
                  title: 'Push Alerts',
                  subtitle: 'Toggle ping sounds rules',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Edit ───────────────────────────────────────────
  Widget _buildEditPanel(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenHeader(
          title: 'Edit Profile',
          onBack: () => setState(() => _viewMode = 'view'),
          trailing: TextButton(
            onPressed: () => _save(state),
            child: const Text('SAVE',
                style: TextStyle(
                    color: AppTheme.gold, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              EditableTextField(
                  label: 'Full Name', controller: _nameController),
              EditableTextField(
                  label: 'Campus / Location',
                  controller: _locationController),
              EditableTextField(
                  label: 'Bio', controller: _bioController, maxLines: 4),
            ],
          ),
        ),
      ],
    );
  }

  // ── View ───────────────────────────────────────────
  Widget _buildViewPanel(AppState state, User user) {
    final location = user.campus.isNotEmpty ? user.campus : user.house;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenHeader(
          title: 'Profile',
          trailing: IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textLight),
            onPressed: () => setState(() => _viewMode = 'settings'),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              // identity card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.navySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.gold,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                    color: AppTheme.navy,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _openEdit(user),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: AppTheme.navyElevated,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.edit,
                                    color: AppTheme.textLight, size: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,
                                  style: const TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(location,
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(user.email,
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white10, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MetricItem(
                            value: '${state.myEvents.length}', label: 'RSVPs'),
                        MetricItem(
                            value: '${state.otherUsers.length}',
                            label: 'Network'),
                        MetricItem(
                            value: '${user.skills.length}', label: 'Skills'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.navySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _tabToggle(0, 'About'),
                    _tabToggle(1, 'RSVPs (${state.myEvents.length})'),
                    _tabToggle(2, 'Skills'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              if (_activeToggleIndex == 0) ..._aboutTab(state, user),
              if (_activeToggleIndex == 1) ..._rsvpsTab(state),
              if (_activeToggleIndex == 2) ..._skillsTab(state, user),

              const SizedBox(height: 12),
              // sign out
              InkWell(
                onTap: state.logout,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_outlined,
                          color: Colors.redAccent, size: 20),
                      SizedBox(width: 16),
                      Text('Sign Out',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // ── About tab ───────────────────────────────────────
  List<Widget> _aboutTab(AppState state, User user) {
    return [
      _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bio',
                    style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _openEdit(user),
                  child: const Icon(Icons.edit_outlined,
                      color: AppTheme.textMuted, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user.bio.isNotEmpty ? user.bio : 'No bio yet. Tap edit to add one.',
              style: const TextStyle(
                  color: AppTheme.textLight, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      if (user.seekingRoles.isNotEmpty) ...[
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Looking for teammates in',
                  style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in user.seekingRoles)
                    CustomChip(
                        label: r,
                        textColor: AppTheme.gold,
                        borderColor: AppTheme.gold),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
      ActionMenuRow(
        icon: Icons.bookmark_outline,
        iconColor: AppTheme.gold,
        title: 'My RSVPs',
        subtitle: '${state.myEvents.length} events & opportunities',
        onTap: () => setState(() => _activeToggleIndex = 1),
      ),
      ActionMenuRow(
        icon: Icons.people_outline,
        iconColor: AppTheme.sage,
        title: 'Find Teammates',
        subtitle: 'Skill-based matching',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FindTeammatesScreen())),
      ),
      ActionMenuRow(
        icon: Icons.star_border_outlined,
        iconColor: AppTheme.gold,
        title: 'Saved Opportunities',
        subtitle: '${state.savedOpportunities.length} bookmarked',
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const SavedOpportunitiesScreen())),
      ),
    ];
  }

  // ── RSVPs tab ───────────────────────────────────────
  List<Widget> _rsvpsTab(AppState state) {
    final events = state.myEvents;
    if (events.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 32),
          child: Center(
            child: Text("You haven't RSVP'd to anything yet.",
                style: TextStyle(color: AppTheme.textMuted)),
          ),
        ),
      ];
    }
    return [
      for (final o in events)
        RsvpEventCard(
          title: o.title,
          dateText: formatDate(o.date),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OpportunityDetailScreen(opportunityId: o.id)),
          ),
        ),
    ];
  }

  // ── Skills tab ──────────────────────────────────────
  List<Widget> _skillsTab(AppState state, User user) {
    return [
      _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Skills',
                style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
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
                DottedAddChip(
                  label: 'Add skill',
                  onTap: () => _addFromOptions(
                    title: 'Add a skill',
                    options: SkillOptions.skills,
                    existing: user.skills,
                    onPick: (v) =>
                        state.updateSkills([...user.skills, v]),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white10, height: 1),
            ),
            const Text('Seeking (for teamwork)',
                style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in user.seekingRoles)
                  Chip(
                    label: Text(r),
                    onDeleted: () => state.setSeekingRoles(
                        user.seekingRoles.where((x) => x != r).toList()),
                  ),
                DottedAddChip(
                  label: 'Add role',
                  onTap: () => _addFromOptions(
                    title: 'Add a role you seek',
                    options: SkillOptions.teammateRoles,
                    existing: user.seekingRoles,
                    onPick: (v) =>
                        state.setSeekingRoles([...user.seekingRoles, v]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  void _addFromOptions({
    required String title,
    required List<String> options,
    required List<String> existing,
    required ValueChanged<String> onPick,
  }) {
    final remaining = options.where((o) => !existing.contains(o)).toList();
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (remaining.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nothing left to add.'),
              ),
            for (final o in remaining)
              ListTile(
                title: Text(o),
                onTap: () {
                  onPick(o);
                  Navigator.pop(sheetCtx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.navySurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );

  Widget _tabToggle(int index, String title) {
    final isSelected = _activeToggleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeToggleIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppTheme.navy : AppTheme.textMuted,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

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
            const Text("You're not signed in.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
