import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import 'opportunity_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.notifications;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Notifications',
              onBack: () => Navigator.pop(context),
              trailing: state.unreadCount > 0
                  ? TextButton(
                      onPressed: state.markAllRead,
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(color: AppTheme.gold),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: items.isEmpty
                  ? const _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      children: [
                        for (final n in items) _NotificationCard(notification: n),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final accent = n.type.accent;

    return InkWell(
      onTap: () {
        context.read<AppState>().markRead(n.id);
        if (n.opportunityId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OpportunityDetailScreen(opportunityId: n.opportunityId!),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // Unread cards sit on a slightly elevated surface so they stand out.
          color: n.isRead ? AppTheme.navySurface : AppTheme.navyElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isRead
                ? const Color(0x1AFFFFFF)
                : AppTheme.gold.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading type icon tile.
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(n.type.icon, size: 22, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontWeight:
                                n.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _relativeTime(n.timestamp),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11),
                      ),
                      // Unread dot.
                      if (!n.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: TextStyle(
                      color: n.isRead
                          ? AppTheme.textMuted
                          : AppTheme.textLight.withValues(alpha: 0.85),
                      fontSize: 13,
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
}

/// Compact relative time: "now", "5m", "2h", "3d".
String _relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_outlined,
                size: 56, color: AppTheme.textMuted),
            SizedBox(height: 12),
            Text(
              "You're all caught up.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'New activity on your events and opportunities will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
