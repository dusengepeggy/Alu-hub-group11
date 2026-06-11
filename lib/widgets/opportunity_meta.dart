import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../theme/app_theme.dart';

/// Small shared building blocks for opportunity UI (chips, badges, dates),
/// reused by the card, the detail screen and the post preview.

/// A compact, coloured chip showing an opportunity's type.
class OpportunityTypeChip extends StatelessWidget {
  final OpportunityType type;
  const OpportunityTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: type.accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 13, color: type.accent),
          const SizedBox(width: 5),
          Text(
            type.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: type.accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// The gold "Verified" trust badge for organizer/admin posts.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: AppTheme.gold),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.gold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A short, locale-free date like "Jun 14, 2026".
String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}
