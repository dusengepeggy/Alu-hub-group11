import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/screen_header.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final opportunities = appState.feed;

    final filteredOpportunities = opportunities.where((o) {
      final query = searchQuery.toLowerCase();

      return o.title.toLowerCase().contains(query) ||
          o.organizer.toLowerCase().contains(query) ||
          o.description.toLowerCase().contains(query) ||
          o.skills.any(
            (skill) => skill.toLowerCase().contains(query),
          );
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Discover',
              onBack: () => Navigator.maybePop(context),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText:
                      'Search by title, organisation, or skill...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            Expanded(
              child: filteredOpportunities.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 56,
                              color: AppTheme.textMuted,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No opportunities found',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Try a different search term.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      children: [
                        for (final opportunity
                            in filteredOpportunities)
                          OpportunityCard(
                            opportunity: opportunity,
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
