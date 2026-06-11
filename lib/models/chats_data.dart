import 'package:flutter/material.dart';

// represents an individual message thread
class ChatMessage {
  final String id;
  final String initials;
  final Color avatarColor;
  final String title;
  final String lastMessage;
  final String timeAgo;
  final String? groupTag;
  final int badgeCount;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.initials,
    required this.avatarColor,
    required this.title,
    required this.lastMessage,
    required this.timeAgo,
    this.groupTag,
    this.badgeCount = 0,
    this.isRead = false,
  });
}

// represents the horizontal active group avatars at the top
class ActiveGroup {
  final String initials;
  final String name;
  final Color avatarColor;
  final int badgeCount;

  const ActiveGroup({
    required this.initials,
    required this.name,
    required this.avatarColor,
    this.badgeCount = 0,
  });
}

// mock data to populate UI
class DummyChatData {
  // top row horizontal bubble content items
  static const List<ActiveGroup> activeGroups = [
    ActiveGroup(initials: 'PN', name: 'Pitch', avatarColor: Color(0xFF6236FF), badgeCount: 3),
    ActiveGroup(initials: 'PH', name: 'Pan-Afri...', avatarColor: Color(0xFF0091FF)),
  ];

  // vertical feed messaging card items
  static const List<ChatMessage> allMessages = [
    ChatMessage(
      id: '1',
      initials: 'PN',
      avatarColor: Color(0xFF6236FF),
      title: 'Pitch Night Team 🔥',
      lastMessage: 'Kwame: Let\'s sync tomorrow at 7pm',
      timeAgo: '2m ago',
      groupTag: 'Group - 3 members',
      badgeCount: 3,
    ),
    ChatMessage(
      id: '2',
      initials: 'KA',
      avatarColor: Color(0xFF0091FF),
      title: 'Kwame Asante',
      lastMessage: 'Have you checked the Andela posting?',
      timeAgo: '1h ago',
      badgeCount: 1,
    ),
    ChatMessage(
      id: '3',
      initials: 'PH',
      avatarColor: Color(0xFF00B27A),
      title: 'Pan-African Hackathon Squad',
      lastMessage: 'Mio: I can handle the data pipeline',
      timeAgo: '3h ago',
      groupTag: 'Group - 3 members',
    ),
    ChatMessage(
      id: '4',
      initials: 'FR',
      avatarColor: Color(0xFFFF2D55),
      title: 'Fatima Al-Rashidi',
      lastMessage: 'Thanks for the recommendations!',
      timeAgo: 'Yesterday',
      isRead: true,
    ),
  ];
}

