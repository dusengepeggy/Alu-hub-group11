import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Opportunity detail + RSVP + per-event chat space.
/// STUB: wire up the layout. RSVP and chat methods already exist in AppState.
///
/// TODO(team):
///  - Show full description, date, location, poster + verified badge.
///  - RSVP button: state.toggleRsvp(o) / state.hasRsvped(o).
///  - Chat: state.messagesFor(o.id) to list, state.sendMessage(o.id, text).
///  - Handle the empty-chat state gracefully.
class OpportunityDetailScreen extends StatelessWidget {
  final String opportunityId;
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Find the opportunity from the feed-or-all list.
    final o = state.feed.firstWhere(
      (e) => e.id == opportunityId,
      orElse: () => state.myEvents.firstWhere((e) => e.id == opportunityId),
    );
    return Scaffold(
      appBar: AppBar(title: Text(o.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(o.description, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => state.toggleRsvp(o),
                child: Text(state.hasRsvped(o) ? 'Cancel RSVP' : 'RSVP'),
              ),
              const SizedBox(height: 24),
              const Text('TODO: build chat space here',
                  style: TextStyle(color: Colors.black38)),
            ],
          ),
        ),
      ),
    );
  }
}
