import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/items.dart';
import '../widgets/screen_header.dart';
import 'opportunity_detail_screen.dart';

/// Conversations list: every opportunity that has at least one chat message
/// becomes a conversation. Tapping one opens its discussion thread in the
/// opportunity detail screen. Backed entirely by real [AppState] data.
class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  String _searchQuery = '';

  void _openThread(BuildContext context, Opportunity o) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpportunityDetailScreen(opportunityId: o.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final query = _searchQuery.toLowerCase();

    final conversations = state.conversations.where((o) {
      if (query.isEmpty) return true;
      final last = state.lastMessageFor(o.id);
      return o.title.toLowerCase().contains(query) ||
          (last?.text.toLowerCase().contains(query) ?? false);
    }).toList();

    // The horizontal "active" strip mirrors the most recent conversations.
    final active = state.conversations.take(6).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────
            ScreenHeader(
              title: 'Messages',
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${state.conversations.length} chats',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            // ── Search ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),

            // ── List ─────────────────────────────────────
            Expanded(
              child: state.conversations.isEmpty
                  ? const _EmptyChats()
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        if (active.isNotEmpty) ...[
                          const _SectionLabel('Active'),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 85,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: active.length,
                              itemBuilder: (context, i) {
                                final o = active[i];
                                return ActiveGroupItem(
                                  initials: _initials(o.title),
                                  name: o.title,
                                  color: o.type.accent,
                                  onTap: () => _openThread(context, o),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const _SectionLabel('All messages'),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: conversations.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 32),
                                  child: Center(
                                    child: Text('No conversations found',
                                        style: TextStyle(
                                            color: AppTheme.textMuted)),
                                  ),
                                )
                              : Column(
                                  children: conversations.map((o) {
                                    final last = state.lastMessageFor(o.id);
                                    final subtitle = last == null
                                        ? 'No messages yet'
                                        : '${last.senderName}: ${last.text}';
                                    return MessageCard(
                                      initials: _initials(o.title),
                                      avatarColor: o.type.accent,
                                      title: o.title,
                                      subtitle: subtitle,
                                      time: last == null
                                          ? ''
                                          : _timeAgo(last.timestamp),
                                      tagText: o.type.label,
                                      isRead: true,
                                      isSelected: false,
                                      cardBg: AppTheme.navySurface,
                                      accentYellow: AppTheme.gold,
                                      onTap: () => _openThread(context, o),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Up to two initials derived from an opportunity title.
  String _initials(String title) {
    final parts =
        title.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  /// Compact relative time: "now", "5m", "3h", "2d".
  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 56, color: AppTheme.textMuted),
            SizedBox(height: 12),
            Text('No conversations yet.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
              'Open an opportunity and start the discussion to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
