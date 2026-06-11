import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The kind of activity a notification represents. Drives the leading icon
/// and accent colour shown on the notifications screen.
enum NotificationType { message, rsvp, opportunity, system }

extension NotificationTypeInfo on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.message:
        return Icons.chat_bubble_outline;
      case NotificationType.rsvp:
        return Icons.event_available_outlined;
      case NotificationType.opportunity:
        return Icons.campaign_outlined;
      case NotificationType.system:
        return Icons.notifications_outlined;
    }
  }

  /// A distinct accent colour per type — used for the leading icon tile.
  Color get accent {
    switch (this) {
      case NotificationType.message:
        return const Color(0xFF3CA6E0); // blue
      case NotificationType.rsvp:
        return AppTheme.sage; // sage green
      case NotificationType.opportunity:
        return const Color(0xFF8B6BE8); // violet
      case NotificationType.system:
        return AppTheme.gold; // gold
    }
  }
}

/// A single in-app notification. Named [AppNotification] to avoid clashing
/// with Flutter's own `Notification` class. Kept deliberately simple, like
/// [Message] — a plain data holder seeded from mock data.
class AppNotification {
  final String id;
  final String userId; // recipient
  final NotificationType type;
  final String title;
  final String body;

  /// Optional deep-link target: when set, tapping opens that opportunity.
  final String? opportunityId;
  final DateTime timestamp;

  /// Mutable so we can flip it when the user reads the notification, mirroring
  /// how [Opportunity.attendees] is mutated in place.
  bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.opportunityId,
    this.isRead = false,
  });
}
