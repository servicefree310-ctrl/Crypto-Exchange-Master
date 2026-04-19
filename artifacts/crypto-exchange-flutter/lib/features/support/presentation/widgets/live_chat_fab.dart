import 'package:flutter/material.dart';
import '../pages/live_chat_page.dart';

class LiveChatFab extends StatelessWidget {
  const LiveChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openLiveChat(context),
      backgroundColor: const Color(0xFF00C851),
      heroTag: "live_chat_fab",
      child: const Icon(
        Icons.chat_bubble,
        color: Colors.white,
      ),
    );
  }

  void _openLiveChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveChatPage(),
      ),
    );
  }
}
