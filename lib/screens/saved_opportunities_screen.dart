import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/screen_header.dart';

/// Opportunities the current user has bookmarked.
class SavedOpportunitiesScreen extends StatelessWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<AppState>().savedOpportunities;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Saved Opportunities',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: saved.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_border,
                                size: 56, color: AppTheme.textMuted),
                            SizedBox(height: 12),
                            Text('Nothing saved yet.',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(
                                'Tap the bookmark on any opportunity to save it.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final o in saved)
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
