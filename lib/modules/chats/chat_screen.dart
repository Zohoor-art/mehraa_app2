
import 'package:flutter/material.dart';
import 'recent_chats.dart';


class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RecentChats(),
        ],
      ),
    );
  }
}
