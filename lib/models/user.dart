import 'package:flutter/material.dart';

/// The three access tiers in ALU Hub.
///
/// This enum is the heart of our "trust & access" design: everyone starts
/// as a [student]. A student can request to become an [organizer]; an
/// [admin] approves that request. Only organizers and admins can post
/// opportunities, which is how we keep the feed trustworthy.
enum UserRole { student, organizer, admin }

extension UserRoleLabel on UserRole {
  /// Human-readable label shown in the UI (e.g. on the profile screen).
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.organizer:
        return 'Verified Organizer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  /// Whether this role is allowed to create opportunity posts.
  bool get canPost => this == UserRole.organizer || this == UserRole.admin;
}

class User {
  final String id;
  final String name;
  final String email;
  final String house; // ALU house / campus, e.g. "Ubuntu", "Kigali"
  final String campus; // e.g. "Kigali, Rwanda"
  final String bio;
  UserRole role;

  /// Skills the user has (used for teammate matching + discovery).
  final List<String> skills;

  /// Roles the user is looking for in teammates (e.g. "Backend Dev").
  final List<String> seekingRoles;

  /// Whether the user is open to being matched with teammates.
  bool lookingForTeammates;

  /// Opportunity ids the user has bookmarked/saved.
  final Set<String> savedOpportunityIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.house,
    this.campus = '',
    this.bio = '',
    this.role = UserRole.student,
    List<String>? skills,
    List<String>? seekingRoles,
    this.lookingForTeammates = false,
    Set<String>? savedOpportunityIds,
  })  : skills = skills ?? <String>[],
        seekingRoles = seekingRoles ?? <String>[],
        savedOpportunityIds = savedOpportunityIds ?? <String>{};

  /// Initials used as a lightweight avatar (no image assets needed).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  // --- Persistence helpers (used by SharedPreferences) ---
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'house': house,
        'campus': campus,
        'bio': bio,
        'role': role.name,
        'skills': skills,
        'seekingRoles': seekingRoles,
        'lookingForTeammates': lookingForTeammates,
        'savedOpportunityIds': savedOpportunityIds.toList(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        house: json['house'] as String,
        campus: (json['campus'] as String?) ?? '',
        bio: (json['bio'] as String?) ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.student,
        ),
        skills: (json['skills'] as List?)?.cast<String>() ?? <String>[],
        seekingRoles:
            (json['seekingRoles'] as List?)?.cast<String>() ?? <String>[],
        lookingForTeammates: (json['lookingForTeammates'] as bool?) ?? false,
        savedOpportunityIds:
            (json['savedOpportunityIds'] as List?)?.cast<String>().toSet() ??
                <String>{},
      );
}
