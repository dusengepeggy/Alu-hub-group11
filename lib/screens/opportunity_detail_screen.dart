import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final String opportunityId;
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Resolve the event by id across ALL opportunities, so the detail page
    // works regardless of the active feed filter or RSVP state.
    final o = state.opportunityById(widget.opportunityId);

    if (o == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Opportunity not found.')),
      );
    }

    final messages = state.messagesFor(o.id);
    final meId = state.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: Text(o.title)),
      body: Column(
        children: [
          // ── Detail + chat list ───────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // type + verified badge
                Row(
                  children: [
                    Icon(o.type.icon, color: AppTheme.gold, size: 18),
                    const SizedBox(width: 6),
                    Text(o.type.label,
                        style: const TextStyle(
                            color: AppTheme.gold, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (o.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 13, color: AppTheme.navy),
                            SizedBox(width: 4),
                            Text('Verified',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.navy)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // title
                Text(o.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // poster, location, attendees
                _infoRow(Icons.person_outline, o.posterName),
                _infoRow(Icons.location_on_outlined, o.location),
                _infoRow(Icons.people_outline, '${o.attendeeCount} going'),
                const SizedBox(height: 16),

                // description
                Text(o.description,
                    style: const TextStyle(fontSize: 15, height: 1.6)),
                const SizedBox(height: 20),

                // RSVP button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => state.toggleRsvp(o),
                    child:
                        Text(state.hasRsvped(o) ? 'Cancel RSVP ✓' : 'RSVP'),
                  ),
                ),
                const SizedBox(height: 28),

                // discussion header
                const Text('Discussion',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),

                // messages
                if (messages.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No messages yet. Start the conversation!',
                          style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                else
                  ...messages
                      .map((msg) => _bubble(context, msg, msg.senderId == meId)),
              ],
            ),
          ),

          // ── Chat input ───────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: AppTheme.navySurface,
              border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Write a message...',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final text = _chatController.text.trim();
                    if (text.isEmpty) return;
                    state.sendMessage(o.id, text);
                    _chatController.clear();
                  },
                  icon: const Icon(Icons.send_rounded),
                  color: AppTheme.gold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A single chat bubble: right-aligned + gold for the current user,
  /// left-aligned + dark for everyone else.
  Widget _bubble(BuildContext context, Message msg, bool isMine) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    final bubbleColor = isMine ? AppTheme.gold : AppTheme.navyElevated;
    final textColor = isMine ? AppTheme.navy : AppTheme.textLight;
    const radius = Radius.circular(14);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: isMine ? radius : Radius.zero,
              bottomRight: isMine ? Radius.zero : radius,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(msg.senderName,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold)),
                ),
              Text(msg.text,
                  style: TextStyle(fontSize: 13, color: textColor)),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _time(msg.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine
                        ? AppTheme.navy.withValues(alpha: 0.6)
                        : AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppTheme.textMuted),
            const SizedBox(width: 6),
            Text(text,
                style:
                    const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      );
}