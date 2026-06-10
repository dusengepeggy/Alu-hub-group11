class Message {
  final String id;
  final String opportunityId; // REQUIRED
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.opportunityId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });
}