import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_meta.dart';

/// Admin panel: review pending organizer requests + moderate posts.
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Moderation'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RequestsTab(),
            _ModerationTab(),
          ],
        ),
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.pendingRequests;
    if (pending.isEmpty) {
      return const _Empty(
        icon: Icons.inbox_outlined,
        text: 'No pending requests.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final r in pending)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${r.userName} · ${r.userHouse}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(r.reason,
                      style: const TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        label: const Text('Deny',
                            style: TextStyle(color: Colors.redAccent)),
                        onPressed: () => state.denyRequest(r),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        onPressed: () => state.approveRequest(r),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ModerationTab extends StatelessWidget {
  const _ModerationTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final posts = state.allOpportunities;
    if (posts.isEmpty) {
      return const _Empty(
        icon: Icons.flag_outlined,
        text: 'No posts to moderate.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final o in posts)
          Card(
            child: ListTile(
              leading: Icon(o.type.icon, color: o.type.accent),
              title: Text(o.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Row(
                children: [
                  OpportunityTypeChip(type: o.type),
                  if (o.isFlagged) ...[
                    const SizedBox(width: 8),
                    const Text('Flagged · hidden',
                        style: TextStyle(
                            fontSize: 11, color: Colors.redAccent)),
                  ],
                ],
              ),
              trailing: IconButton(
                tooltip: o.isFlagged ? 'Unflag' : 'Flag',
                icon: Icon(
                  o.isFlagged ? Icons.flag : Icons.outlined_flag,
                  color: o.isFlagged ? Colors.redAccent : AppTheme.textMuted,
                ),
                onPressed: () => state.toggleFlag(o),
              ),
            ),
          ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
