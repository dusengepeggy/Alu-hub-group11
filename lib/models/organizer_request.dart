enum RequestStatus { pending, approved, denied }

extension RequestStatusLabel on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.denied:
        return 'Denied';
    }
  }
}

class OrganizerRequest {
  final String id;
  final String userId;
  final String userName;
  final String userHouse;

  /// Why they should be trusted to post (e.g. "President of the Robotics Club").
  final String reason;

  RequestStatus status;

  OrganizerRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userHouse,
    required this.reason,
    this.status = RequestStatus.pending,
  });
}
