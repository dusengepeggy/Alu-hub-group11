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

  /// All opportunities (including flagged) — used by the admin moderation list.
  List<Opportunity> get allOpportunities => List.unmodifiable(_opportunities);

  /// Every other user — used for teammate matching.
  List<User> get otherUsers =>
      _users.where((u) => u.id != _currentUser?.id).toList();

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

  /// Keyword search across non-flagged opportunities, matching title,
  /// location, description and type label. An empty query returns all
  /// non-flagged opportunities. Results are sorted soonest-first.
  List<Opportunity> search(String query) {
    final q = query.trim().toLowerCase();
    final list = _opportunities.where((o) => !o.isFlagged).where((o) {
      if (q.isEmpty) return true;
      return o.title.toLowerCase().contains(q) ||
          o.location.toLowerCase().contains(q) ||
          o.description.toLowerCase().contains(q) ||
          o.organizer.toLowerCase().contains(q) ||
          o.type.label.toLowerCase().contains(q) ||
          o.skills.any((s) => s.toLowerCase().contains(q));
    }).toList();
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

  /// Opportunities the current user has bookmarked ("Saved").
  List<Opportunity> get savedOpportunities {
    final user = _currentUser;
    if (user == null) return [];
    return _opportunities
        .where((o) => user.savedOpportunityIds.contains(o.id))
        .toList();
  }

  /// Find an opportunity by id (across all, including flagged).
  Opportunity? opportunityById(String id) {
    for (final o in _opportunities) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Opportunities that have at least one chat message, newest activity first.
  /// These back the Messages ("Chats") conversation list.
  List<Opportunity> get conversations {
    final withMsgs = _opportunities.where(
      (o) => _messages.any((m) => m.opportunityId == o.id),
    );
    final list = withMsgs.toList();
    list.sort((a, b) {
      final ta = lastMessageFor(a.id)?.timestamp;
      final tb = lastMessageFor(b.id)?.timestamp;
      if (ta == null || tb == null) return 0;
      return tb.compareTo(ta);
    });
    return list;
  }

  Message? lastMessageFor(String opportunityId) {
    Message? last;
    for (final m in _messages) {
      if (m.opportunityId != opportunityId) continue;
      if (last == null || m.timestamp.isAfter(last.timestamp)) last = m;
    }
    return last;
  }

  /// Suggested teammates: other users who are open to teammates or share a
  /// skill with the current user, ranked by number of shared skills.
  List<User> findTeammates() {
    final me = _currentUser;
    if (me == null) return [];
    final mySkills = me.skills.map((s) => s.toLowerCase()).toSet();
    int shared(User u) =>
        u.skills.where((s) => mySkills.contains(s.toLowerCase())).length;
    final list = otherUsers
        .where((u) => u.lookingForTeammates || shared(u) > 0)
        .toList();
    list.sort((a, b) => shared(b).compareTo(shared(a)));
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
    required String campus,
    required String password,
    List<String>? skills,
  }) {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return 'Please fill in all required fields.';
    }
    if (!email.contains('@')) {
      return 'Please enter a valid email address.';
    }
    if (campus.trim().isEmpty) {
      return 'Please select your campus.';
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
      // We use the chosen campus as the user's house/campus identity.
      house: campus.trim(),
      campus: campus.trim(),
      skills: skills ?? <String>[],
      // Everyone starts as a student — the core of our access model.
      role: UserRole.student,
    );
    _users.add(user);
    _currentUser = user;
    _persistUser();
    notifyListeners();
    return null;
  }

  /// Update the current user's skills (e.g. from onboarding or profile).
  void updateSkills(List<String> skills) {
    final user = _currentUser;
    if (user == null) return;
    user.skills
      ..clear()
      ..addAll(skills);
    _persistUser();
    notifyListeners();
  }

  /// Update who the current user is looking for in teammates.
  void setSeekingRoles(List<String> roles, {bool? lookingForTeammates}) {
    final user = _currentUser;
    if (user == null) return;
    user.seekingRoles
      ..clear()
      ..addAll(roles);
    if (lookingForTeammates != null) {
      user.lookingForTeammates = lookingForTeammates;
    }
    _persistUser();
    notifyListeners();
  }

  // --- Saved / bookmarked opportunities ---
  bool isSaved(Opportunity o) =>
      _currentUser?.savedOpportunityIds.contains(o.id) ?? false;

  void toggleSaved(Opportunity o) {
    final user = _currentUser;
    if (user == null) return;
    if (user.savedOpportunityIds.contains(o.id)) {
      user.savedOpportunityIds.remove(o.id);
    } else {
      user.savedOpportunityIds.add(o.id);
    }
    _persistUser();
    notifyListeners();
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
    String organizer = '',
    List<String>? skills,
    DateTime? applicationDeadline,
    int? teamSize,
    int? spotsAvailable,
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
      organizer: organizer.trim(),
      skills: skills ?? <String>[],
      applicationDeadline: applicationDeadline,
      teamSize: teamSize,
      spotsAvailable: spotsAvailable,
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
