import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_meta.dart';

/// Opportunity detail: full info, RSVP, save, and a per-event chat space.
class OpportunityDetailScreen extends StatefulWidget {
  final String opportunityId;
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _send(AppState state) {
    final text = _msgController.text;
    if (text.trim().isEmpty) return;
    state.sendMessage(widget.opportunityId, text);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final o = state.opportunityById(widget.opportunityId);
    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This opportunity is no longer available.')),
      );
    }

    final messages = state.messagesFor(o.id);
    final me = state.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(o.type.label)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Gradient banner header.
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: o.type.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(o.type.icon,
                        size: 44, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    OpportunityTypeChip(type: o.type),
                    const Spacer(),
                    if (o.isVerified) const VerifiedBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  o.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (o.organizer.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(o.organizer,
                      style: const TextStyle(color: AppTheme.textMuted)),
                ],
                const SizedBox(height: 14),
                _MetaRow(icon: Icons.event, text: formatDate(o.date)),
                _MetaRow(icon: Icons.place_outlined, text: o.location),
                if (o.applicationDeadline != null)
                  _MetaRow(
                    icon: Icons.timer_outlined,
                    text: 'Deadline: ${formatDate(o.applicationDeadline!)}',
                    color: const Color(0xFFE0823C),
                  ),
                _MetaRow(
                  icon: Icons.people_outline,
                  text: '${o.attendeeCount} going'
                      '${o.interestedCount > 0 ? ' · ${o.interestedCount} interested' : ''}',
                ),
                if (o.teamSize != null || o.spotsAvailable != null)
                  _MetaRow(
                    icon: Icons.groups_outlined,
                    text: [
                      if (o.teamSize != null) 'Teams of ${o.teamSize}',
                      if (o.spotsAvailable != null)
                        '${o.spotsAvailable} spots',
                    ].join(' · '),
                  ),
                const SizedBox(height: 16),
                Text(o.description, style: const TextStyle(height: 1.5)),
                if (o.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Skills',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in o.skills)
                        Chip(
                          label: Text(s),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => state.toggleRsvp(o),
                        icon: Icon(state.hasRsvped(o)
                            ? Icons.check_circle
                            : Icons.event_available_outlined),
                        label: Text(state.hasRsvped(o) ? "RSVP'd" : 'RSVP'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.outlined(
                      onPressed: () => state.toggleSaved(o),
                      icon: Icon(state.isSaved(o)
                          ? Icons.bookmark
                          : Icons.bookmark_border),
                      color: state.isSaved(o) ? AppTheme.gold : null,
                    ),
                  ],
                ),
                const Divider(height: 40),
                const Text('Discussion',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (messages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No messages yet. Start the conversation!',
                          style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                else
                  for (final m in messages)
                    _ChatBubble(
                      senderName: m.senderName,
                      text: m.text,
                      isMine: m.senderId == me?.id,
                    ),
              ],
            ),
          ),
          // Compose bar.
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(state),
                      decoration: const InputDecoration(
                        hintText: 'Message…',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _send(state),
                    icon: const Icon(Icons.send),
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

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _MetaRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color ?? AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String senderName;
  final String text;
  final bool isMine;
  const _ChatBubble({
    required this.senderName,
    required this.text,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMine ? AppTheme.gold : AppTheme.navyElevated,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isMine ? AppTheme.navy : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                  color: isMine ? AppTheme.navy : AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
