import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/screen_header.dart';

/// "My Events": opportunities the current user has RSVP'd to.
class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<AppState>().myEvents;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'My Events'),
            Expanded(
              child: events.isEmpty
                  ? const _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final o in events)
                          OpportunityCard(opportunity: o),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
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
            Icon(Icons.event_busy_outlined, size: 56, color: AppTheme.textMuted),
            SizedBox(height: 12),
            Text(
              "You haven't RSVP'd to anything yet.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Browse the feed and RSVP to events to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
