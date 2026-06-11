import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/opportunity.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../screens/opportunity_detail_screen.dart';
import 'opportunity_meta.dart';

/// A single opportunity card used across the feed, discover and saved lists,
/// so they stay visually identical. Shows a type-coloured banner, trust
/// badge, key meta, skill tags and a save (bookmark) toggle.
class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityCard({
    super.key,
    required this.opportunity,
  });

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    final state = context.watch<AppState>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpportunityDetailScreen(opportunityId: o.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient banner with the type icon + save button.
            Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: o.type.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(o.type.icon,
                      color: Colors.white.withValues(alpha: 0.95)),
                  const Spacer(),
                  InkWell(
                    onTap: () => state.toggleSaved(o),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        state.isSaved(o)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      OpportunityTypeChip(type: o.type),
                      const Spacer(),
                      if (o.isVerified) const VerifiedBadge(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    o.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    o.organizer.isNotEmpty
                        ? o.organizer
                        : '${o.posterName} · ${o.location}',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.event,
                          size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(formatDate(o.date),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                      const SizedBox(width: 12),
                      const Icon(Icons.people_outline,
                          size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${o.interestedCount > 0 ? o.interestedCount : o.attendeeCount} interested',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  if (o.skills.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in o.skills.take(4)) _SkillTag(s),
                      ],
                    ),
                  ],
                  if (o.applicationDeadline != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Deadline: ${formatDate(o.applicationDeadline!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE0823C),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillTag extends StatelessWidget {
  final String label;
  const _SkillTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.navyElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
      ),
    );
  }
}
