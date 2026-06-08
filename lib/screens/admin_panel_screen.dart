import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Admin panel: review pending organizer requests + moderate posts.
/// STUB with requests wired so you can see the approve flow working.
///
/// TODO(team):
///  - Make this visually polished.
///  - Add a moderation section listing posts with a flag/unflag toggle
///    (state.toggleFlag(o)).
///  - Show empty states for "no pending requests".
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.pendingRequests;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: pending.isEmpty
          ? const Center(child: Text('No pending requests.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final r in pending)
                  Card(
                    child: ListTile(
                      title: Text('${r.userName} · ${r.userHouse}'),
                      subtitle: Text(r.reason),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => state.approveRequest(r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => state.denyRequest(r),
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
