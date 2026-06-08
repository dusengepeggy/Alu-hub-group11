import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// "My Events": opportunities the current user has RSVP'd to.
/// STUB. TODO(team): reuse the feed card widget here once you extract it
/// into widgets/opportunity_card.dart. Handle the empty state nicely.
class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<AppState>().myEvents;
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: events.isEmpty
          ? const Center(child: Text("You haven't RSVP'd to anything yet."))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final o in events)
                  ListTile(title: Text(o.title), subtitle: Text(o.location)),
              ],
            ),
    );
  }
}
