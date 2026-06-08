import 'package:flutter/material.dart';

/// The three access tiers in ALU Connect.
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
  final String house; // ALU house, e.g. "Ubuntu", "Imagine"
  final String bio;
  UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.house,
    this.bio = '',
    this.role = UserRole.student,
  });

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
        'bio': bio,
        'role': role.name,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        house: json['house'] as String,
        bio: (json['bio'] as String?) ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.student,
        ),
      );
}
