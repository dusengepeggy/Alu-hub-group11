import 'package:flutter/material.dart';

enum OpportunityType {
  event,
  hackathon,
  workshop,
  internship,
  startup,
  leadership,
  announcement,
}

extension OpportunityTypeInfo on OpportunityType {
  String get label {
    switch (this) {
      case OpportunityType.event:
        return 'Event';
      case OpportunityType.hackathon:
        return 'Hackathon';
      case OpportunityType.workshop:
        return 'Workshop';
      case OpportunityType.internship:
        return 'Internship';
      case OpportunityType.startup:
        return 'Startup';
      case OpportunityType.leadership:
        return 'Leadership';
      case OpportunityType.announcement:
        return 'Announcement';
    }
  }

  IconData get icon {
    switch (this) {
      case OpportunityType.event:
        return Icons.celebration_outlined;
      case OpportunityType.hackathon:
        return Icons.code_outlined;
      case OpportunityType.workshop:
        return Icons.build_outlined;
      case OpportunityType.internship:
        return Icons.work_outline;
      case OpportunityType.startup:
        return Icons.rocket_launch_outlined;
      case OpportunityType.leadership:
        return Icons.emoji_events_outlined;
      case OpportunityType.announcement:
        return Icons.campaign_outlined;
    }
  }
}

class Opportunity {
  final String id;
  final String title;
  final OpportunityType type;
  final String description;
  final DateTime date;
  final String location;
  final String posterId;
  final String posterName;

  final bool isVerified;

  /// User ids who have RSVP'd. Kept as a Set to avoid duplicates.
  final Set<String> attendees;

  /// Admin moderation flag. A flagged post is hidden from the student feed.
  bool isFlagged;

  Opportunity({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.date,
    required this.location,
    required this.posterId,
    required this.posterName,
    this.isVerified = true,
    Set<String>? attendees,
    this.isFlagged = false,
  }) : attendees = attendees ?? <String>{};

  int get attendeeCount => attendees.length;
}
