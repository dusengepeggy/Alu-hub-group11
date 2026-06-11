import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../data/skill_options.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_meta.dart';
import 'posted_success_screen.dart';

/// 3-step "Post an Opportunity" wizard (organizers/admins only):
///   1. Basic Info   2. Details   3. Skills & Preview → Publish.
class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() =>
      _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  int _step = 0;

  // Form state.
  OpportunityType _type = OpportunityType.event;
  final _title = TextEditingController();
  final _organizer = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _teamSize = TextEditingController();
  final _spots = TextEditingController();
  bool _remote = false;
  DateTime? _date;
  DateTime? _deadline;
  final Set<String> _skills = {};

  @override
  void dispose() {
    _title.dispose();
    _organizer.dispose();
    _location.dispose();
    _description.dispose();
    _teamSize.dispose();
    _spots.dispose();
    super.dispose();
  }

  void _next() {
    // Lightweight per-step validation.
    if (_step == 0 && _title.text.trim().isEmpty) {
      _toast('Please add a title.');
      return;
    }
    if (_step == 1) {
      if (_date == null) {
        _toast('Please pick a date.');
        return;
      }
      if (_description.text.trim().isEmpty) {
        _toast('Please add a description.');
        return;
      }
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
  }

  void _publish() {
    final state = context.read<AppState>();
    final error = state.createOpportunity(
      title: _title.text,
      type: _type,
      description: _description.text,
      date: _date ?? DateTime.now(),
      location: _remote ? 'Remote' : _location.text,
      organizer: _organizer.text,
      skills: _skills.toList(),
      applicationDeadline: _deadline,
      teamSize: int.tryParse(_teamSize.text),
      spotsAvailable: int.tryParse(_spots.text),
    );
    if (error != null) {
      _toast(error);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostedSuccessScreen()),
    ).then((_) => _reset());
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      _step = 0;
      _type = OpportunityType.event;
      _title.clear();
      _organizer.clear();
      _location.clear();
      _description.clear();
      _teamSize.clear();
      _spots.clear();
      _remote = false;
      _date = null;
      _deadline = null;
      _skills.clear();
    });
  }

  void _toast(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pickDate({required bool deadline}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (deadline) {
        _deadline = picked;
      } else {
        _date = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Step 1 of 3 — Basic Info',
      'Step 2 of 3 — Details',
      'Step 3 of 3 — Skills & Preview',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post an Opportunity'),
        actions: [
          if (_step == 0)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.maybePop(context),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / 3,
                  minHeight: 5,
                  backgroundColor: AppTheme.navyElevated,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(titles[_step],
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: switch (_step) {
                  0 => _basicInfo(),
                  1 => _details(),
                  _ => _skillsAndPreview(),
                },
              ),
            ),
            _navBar(),
          ],
        ),
      ),
    );
  }

  // --- Step 1 ---
  Widget _basicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Type of Opportunity'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final t in OpportunityType.values)
              _TypeTile(
                type: t,
                selected: _type == t,
                onTap: () => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Title *'),
        const SizedBox(height: 6),
        TextField(
          controller: _title,
          decoration: const InputDecoration(hintText: 'e.g. AI Hackathon 2026'),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Organizer / Company *'),
        const SizedBox(height: 6),
        TextField(
          controller: _organizer,
          decoration: const InputDecoration(
              hintText: 'e.g. Google, ALU Innovation Lab'),
        ),
        const SizedBox(height: 16),
        const _InfoBanner(),
      ],
    );
  }

  // --- Step 2 ---
  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Date / Start Date'),
        const SizedBox(height: 6),
        _DateField(
          label: _date == null ? 'Select a date' : formatDate(_date!),
          onTap: () => _pickDate(deadline: false),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Application Deadline'),
        const SizedBox(height: 6),
        _DateField(
          label: _deadline == null ? 'Optional' : formatDate(_deadline!),
          onTap: () => _pickDate(deadline: true),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Location'),
        const SizedBox(height: 6),
        Row(
          children: [
            ChoiceChip(
              label: const Text('In-person'),
              selected: !_remote,
              onSelected: (_) => setState(() => _remote = false),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Remote'),
              selected: _remote,
              onSelected: (_) => setState(() => _remote = true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_remote)
          TextField(
            controller: _location,
            decoration: const InputDecoration(hintText: 'e.g. ALU, Rwanda'),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('Team size'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _teamSize,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 4'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('Spots available'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _spots,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 20'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Description *'),
        const SizedBox(height: 6),
        TextField(
          controller: _description,
          maxLines: 4,
          decoration:
              const InputDecoration(hintText: 'What is this about?'),
        ),
      ],
    );
  }

  // --- Step 3 ---
  Widget _skillsAndPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Skills Required'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in SkillOptions.skills)
              FilterChip(
                label: Text(s),
                selected: _skills.contains(s),
                onSelected: (on) => setState(() {
                  on ? _skills.add(s) : _skills.remove(s);
                }),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Preview'),
        const SizedBox(height: 10),
        _PreviewCard(
          type: _type,
          title: _title.text.isEmpty ? 'Your title' : _title.text,
          organizer: _organizer.text,
          date: _date,
        ),
      ],
    );
  }

  Widget _navBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _back,
                  child: const Text('← Back'),
                ),
              ),
            if (_step > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _step < 2 ? _next : _publish,
                child: Text(_step < 2 ? 'Continue →' : 'Publish Opportunity ✨'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700),
      );
}

class _TypeTile extends StatelessWidget {
  final OpportunityType type;
  final bool selected;
  final VoidCallback onTap;
  const _TypeTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.navySurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? type.accent : const Color(0x1AFFFFFF),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(type.icon, color: type.accent),
            const SizedBox(height: 6),
            Text(type.label,
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppTheme.gold),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Who can post? Verified organizers post events and startup '
              'initiatives. Jobs/internships are verified by ALU Career Services.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: const InputDecoration(),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppTheme.textMuted),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final OpportunityType type;
  final String title;
  final String organizer;
  final DateTime? date;
  const _PreviewCard({
    required this.type,
    required this.title,
    required this.organizer,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: type.gradient),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(type.icon, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OpportunityTypeChip(type: type),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  [
                    if (organizer.isNotEmpty) organizer,
                    if (date != null) formatDate(date!),
                  ].join(' · '),
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
