
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/chats/all_chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/components/recent_chats.dart';


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
          AllChats(),
        ],
      ),
    );
  }
}
