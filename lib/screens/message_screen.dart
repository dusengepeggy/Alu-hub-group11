import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final List<Message> _messages = [];

  Timer? _timer;

  final List<String> autoMessages = [
    'Welcome to ALU Connect!',
    'A new opportunity has been posted.',
    'Your application was received.',
    'You have a new connection request.',
    'A networking event starts tomorrow.',
    'Check out the latest internships.',
  ];

  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();

    _messages.add(
      Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        opportunityId: '', // Replace with actual opportunity ID if available
        senderId: '', // Replace with actual sender ID if available
        senderName: 'ALU Connect',
        text: 'Welcome to ALU Connect! Start exploring opportunities and connecting with others.',
        timestamp: DateTime.now(),
      ),
    );

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        if (!mounted) return;

        setState(() {
          _messages.add(
            Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              opportunityId: '', // Replace with actual opportunity ID if available
              senderId: '', // Replace with actual sender ID if available
              senderName: 'ALU Connect',
              text: autoMessages[_messageIndex % autoMessages.length],
              timestamp: DateTime.now(),
            ),
          );

          _messageIndex++;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.message),
              ),
              title: Text(message.senderName),
              subtitle: Text(message.text),
              trailing: Text(
                _formatTime(message.timestamp),
              ),
            ),
          );
        },
      ),
    );
  }
}