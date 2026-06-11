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

  /// A distinct accent colour per type — used for the type chip/badge.
  Color get accent {
    switch (this) {
      case OpportunityType.event:
        return const Color(0xFFE0823C); // warm orange
      case OpportunityType.hackathon:
        return const Color(0xFF8B6BE8); // violet
      case OpportunityType.workshop:
        return const Color(0xFF3CA6E0); // blue
      case OpportunityType.internship:
        return const Color(0xFF6BA88F); // sage green
      case OpportunityType.startup:
        return const Color(0xFFE05C7E); // pink
      case OpportunityType.leadership:
        return const Color(0xFFF5B528); // gold
      case OpportunityType.announcement:
        return const Color(0xFF9AA8BC); // muted
    }
  }

  /// A two-colour gradient used for card "banner" headers (no image assets).
  List<Color> get gradient {
    final base = accent;
    return [base.withValues(alpha: 0.85), base.withValues(alpha: 0.45)];
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

  /// Organising body / company (e.g. "ALU Innovation Lab", "Flutterwave").
  final String organizer;

  /// Skills relevant to this opportunity (used in discovery + matching).
  final List<String> skills;

  /// Optional application deadline (e.g. internships).
  final DateTime? applicationDeadline;

  /// Optional team / capacity hints.
  final int? teamSize;
  final int? spotsAvailable;

  /// Lightweight "interested" signal, separate from confirmed RSVPs.
  final int interestedCount;

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
    this.organizer = '',
    List<String>? skills,
    this.applicationDeadline,
    this.teamSize,
    this.spotsAvailable,
    this.interestedCount = 0,
    this.isVerified = true,
    Set<String>? attendees,
    this.isFlagged = false,
  })  : skills = skills ?? <String>[],
        attendees = attendees ?? <String>{};

  int get attendeeCount => attendees.length;
}
