import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import 'opportunity_detail_screen.dart';

/// Messages ("Chats"): a list of per-event group conversations. Each
/// opportunity with messages is one group thread; tapping opens its chat.
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final conversations = state.conversations;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversations.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.forum_outlined,
                        size: 56, color: AppTheme.textMuted),
                    SizedBox(height: 12),
                    Text('No conversations yet.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      'Open an opportunity and start its discussion.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final o = conversations[index];
                return _ConversationTile(opportunity: o);
              },
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Opportunity opportunity;
  const _ConversationTile({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final o = opportunity;
    final last = state.lastMessageFor(o.id);
    final count = state.messagesFor(o.id).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: o.type.accent.withValues(alpha: 0.25),
          child: Icon(o.type.icon, color: o.type.accent, size: 20),
        ),
        title: Text(
          o.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          last != null ? '${last.senderName}: ${last.text}' : 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              last != null ? _ago(last.timestamp) : '',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 4),
            Text('$count msgs',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpportunityDetailScreen(opportunityId: o.id),
            ),
          );
        },
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
