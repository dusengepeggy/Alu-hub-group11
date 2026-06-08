import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/user.dart';

/// Profile / identity screen. Shows who you are, your house, your role and
/// verification status, and (for students) a button to request organizer
/// rights. STUB with the request flow wired.
///
/// TODO(team):
///  - Polish the layout (avatar from user.initials, bio, my-RSVP count).
///  - Improve the request dialog UX and show pending status clearly.
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
    final user = state.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: state.logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 36, child: Text(user.initials)),
            const SizedBox(height: 12),
            Text(user.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${user.house} House · ${user.role.label}'),
            const SizedBox(height: 20),
            if (user.role == UserRole.student)
              state.currentUserHasPendingRequest()
                  ? const Chip(label: Text('Organizer request pending'))
                  : FilledButton(
                      onPressed: () => _requestDialog(context),
                      child: const Text('Request organizer access'),
                    ),
          ],
        ),
      ),
    );
  }
}
