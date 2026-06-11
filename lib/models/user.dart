import 'package:flutter/material.dart';

class User {
  final String id;
  String name;
  final String email;
  final String house; // ALU house / campus, e.g. "Ubuntu", "Kigali"
  String campus; // e.g. "Kigali, Rwanda"
  String bio;

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
        skills: (json['skills'] as List?)?.cast<String>() ?? <String>[],
        seekingRoles:
            (json['seekingRoles'] as List?)?.cast<String>() ?? <String>[],
        lookingForTeammates: (json['lookingForTeammates'] as bool?) ?? false,
        savedOpportunityIds:
            (json['savedOpportunityIds'] as List?)?.cast<String>().toSet() ??
                <String>{},
      );
}
