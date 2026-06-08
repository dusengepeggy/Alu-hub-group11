import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/opportunity.dart';
import '../models/organizer_request.dart';
import '../models/message.dart';
import '../data/mock_data.dart';

/// AppState is the single source of truth for the whole app.
///
/// It extends [ChangeNotifier]: every screen "listens" to it, and whenever
/// we change something and call [notifyListeners], the listening screens
/// rebuild automatically. This is the state-handling story we explain in the
/// demo — one central object, simple methods that mutate it, and the UI
/// reacts.
///
/// Persistence is intentionally minimal and safe: we only persist the
/// currently logged-in user (so the session survives an app restart) using
/// SharedPreferences. Everything else lives in memory and is seeded from
/// [MockData], which is all the brief requires.
class AppState extends ChangeNotifier {
  static const _kCurrentUserKey = 'current_user';

  final List<User> _users = MockData.users();
  final List<Opportunity> _opportunities = MockData.opportunities();
  final List<OrganizerRequest> _requests = MockData.requests();
  final List<Message> _messages = MockData.messages();

  User? _currentUser;
  OpportunityType? _activeFilter; // null == show all types

  // --- Read-only getters for the UI ---
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  OpportunityType? get activeFilter => _activeFilter;

  List<OrganizerRequest> get pendingRequests =>
      _requests.where((r) => r.status == RequestStatus.pending).toList();

  /// The feed: never shows flagged posts, applies the active type filter,
  /// and sorts soonest-first so the next thing happening is on top.
  List<Opportunity> get feed {
    final list = _opportunities
        .where((o) => !o.isFlagged)
        .where((o) => _activeFilter == null || o.type == _activeFilter)
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Opportunities the current user has RSVP'd to ("My Events").
  List<Opportunity> get myEvents {
    final id = _currentUser?.id;
    if (id == null) return [];
    final list =
        _opportunities.where((o) => o.attendees.contains(id)).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  // --- Session restore (called once at startup) ---
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCurrentUserKey);
    if (raw != null) {
      try {
        final saved = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        // Prefer the live user object (keeps role changes consistent),
        // falling back to the saved snapshot.
        _currentUser = _users.firstWhere(
          (u) => u.id == saved.id,
          orElse: () => saved,
        );
      } catch (_) {
        // Corrupt data — ignore and start logged out.
      }
    }
    notifyListeners();
  }

  Future<void> _persistUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser == null) {
      await prefs.remove(_kCurrentUserKey);
    } else {
      await prefs.setString(
          _kCurrentUserKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  // --- Auth ---

  /// Returns null on success, or an error message to show the user.
  String? login(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Please enter your email and password.';
    }
    final match = _users.where(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (match.isEmpty) {
      return 'No account found with that email. Try signing up.';
    }
    _currentUser = match.first;
    _persistUser();
    notifyListeners();
    return null;
  }

  String? signUp({
    required String name,
    required String email,
    required String house,
    required String password,
  }) {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return 'Please fill in all required fields.';
    }
    if (!email.contains('@')) {
      return 'Please enter a valid email address.';
    }
    final exists = _users.any(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (exists) {
      return 'An account with that email already exists.';
    }
    final user = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      house: house,
      // Everyone starts as a student — the core of our access model.
      role: UserRole.student,
    );
    _users.add(user);
    _currentUser = user;
    _persistUser();
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    _persistUser();
    notifyListeners();
  }

  // --- Feed interaction ---
  void setFilter(OpportunityType? type) {
    _activeFilter = type;
    notifyListeners();
  }

  /// Toggle RSVP for the current user on an opportunity.
  void toggleRsvp(Opportunity o) {
    final id = _currentUser?.id;
    if (id == null) return;
    if (o.attendees.contains(id)) {
      o.attendees.remove(id);
    } else {
      o.attendees.add(id);
    }
    notifyListeners();
  }

  bool hasRsvped(Opportunity o) =>
      _currentUser != null && o.attendees.contains(_currentUser!.id);

  // --- Posting (organizers/admins only) ---
  String? createOpportunity({
    required String title,
    required OpportunityType type,
    required String description,
    required DateTime date,
    required String location,
  }) {
    final user = _currentUser;
    if (user == null || !user.role.canPost) {
      return 'You do not have permission to post opportunities.';
    }
    if (title.trim().isEmpty || description.trim().isEmpty) {
      return 'Title and description are required.';
    }
    _opportunities.add(Opportunity(
      id: 'o_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      type: type,
      description: description.trim(),
      date: date,
      location: location.trim(),
      posterId: user.id,
      posterName: user.name,
      isVerified: true, // posted by a verified organizer/admin
    ));
    notifyListeners();
    return null;
  }

  // --- Organizer access requests ---
  bool currentUserHasPendingRequest() {
    final id = _currentUser?.id;
    if (id == null) return false;
    return _requests.any(
        (r) => r.userId == id && r.status == RequestStatus.pending);
  }

  String? submitOrganizerRequest(String reason) {
    final user = _currentUser;
    if (user == null) return 'You must be logged in.';
    if (reason.trim().length < 10) {
      return 'Please give a bit more detail (at least 10 characters).';
    }
    if (currentUserHasPendingRequest()) {
      return 'You already have a pending request.';
    }
    _requests.add(OrganizerRequest(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      userName: user.name,
      userHouse: user.house,
      reason: reason.trim(),
    ));
    notifyListeners();
    return null;
  }

  // --- Admin actions ---
  void approveRequest(OrganizerRequest r) {
    r.status = RequestStatus.approved;
    final user = _users.firstWhere((u) => u.id == r.userId,
        orElse: () => _currentUser!);
    user.role = UserRole.organizer;
    // If the approved user is the one logged in, keep their session fresh.
    if (_currentUser?.id == user.id) _persistUser();
    notifyListeners();
  }

  void denyRequest(OrganizerRequest r) {
    r.status = RequestStatus.denied;
    notifyListeners();
  }

  void toggleFlag(Opportunity o) {
    o.isFlagged = !o.isFlagged;
    notifyListeners();
  }

  // --- Chat ---
  List<Message> messagesFor(String opportunityId) {
    final list = _messages
        .where((m) => m.opportunityId == opportunityId)
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  String? sendMessage(String opportunityId, String text) {
    final user = _currentUser;
    if (user == null) return 'You must be logged in to chat.';
    if (text.trim().isEmpty) return null; // silently ignore empty
    _messages.add(Message(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      opportunityId: opportunityId,
      senderId: user.id,
      senderName: user.name,
      text: text.trim(),
      timestamp: DateTime.now(),
    ));
    notifyListeners();
    return null;
  }
}
