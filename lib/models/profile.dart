import 'package:flutter/material.dart';

// represent user profile summary metrics
class ProfileMetrics {
  final int rsvps;
  final int network;
  final int skills;

  const ProfileMetrics({
    required this.rsvps,
    required this.network,
    required this.skills,
  });
}

/// contain all info for a student profile card
class UserProfile {
  final String name;
  final String course;
  final String location;
  final String year;
  final String initials;
  final Color avatarColor;
  final ProfileMetrics metrics;
  final String bio;

  // constructor to initialize final properties
  const UserProfile({
    required this.name,
    required this.course,
    required this.location,
    required this.year,
    required this.initials,
    required this.avatarColor,
    required this.metrics,
    required this.bio,
  });
}

/// represent an event the user has RSVP'd
class RsvpEvent {
  final String title;
  final String dateText;

  const RsvpEvent({
    required this.title,
    required this.dateText,
  });
}

/// mock data store matching UI
class DummyProfileData {
  static const UserProfile mockUser = UserProfile(
    name: 'Aliné Umuhoza',
    course: 'BSc Computer Science',
    location: 'Kigali, Rwanda',
    year: 'Year 3',
    initials: 'AU',
    avatarColor: Color(0xFFFFB800),
    metrics: ProfileMetrics(rsvps: 3, network: 87, skills: 4),
    bio: 'Passionate about building tech for Africa. Love hackathons and impact-driven startups.',
  );

  static const List<RsvpEvent> mockRsvps = [
    RsvpEvent(title: 'Pitch Night — ALU Innovati...', dateText: 'Jun 14, 2026'),
    RsvpEvent(title: 'Software Engineer Intern ...', dateText: 'Starts Jul 1, 2026'),
    RsvpEvent(title: 'Community Town Up — Ki...', dateText: 'Jun 8, 2026'),
  ];

  static const List<Map<String, dynamic>> mockSkills = [
    {'name': 'React', 'color': Color(0xFF6236FF)},
    {'name': 'Python', 'color': Color(0xFF0091FF)},
    {'name': 'UI/UX', 'color': Color(0xFF00B27A)},
    {'name': 'Data Analysis', 'color': Color(0xFFFF2D55)},
  ];

  static const List<String> mockSeekingTags = [
    'Backend Dev',
    'Product Manager',
    'Designer',
  ];
}

