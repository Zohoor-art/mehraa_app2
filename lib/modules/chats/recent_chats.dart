import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/theme/theme.dart';
import 'chat_room.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({super.key});

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (chatSnapshot.hasError) {
          return Center(child: Text('Error: ${chatSnapshot.error}'));
        }

        // الحصول على جميع المحادثات التي تحتوي على رسائل
        final chatDocs = chatSnapshot.data!.docs;

        return ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatDoc = chatDocs[index];
            final userId = chatDoc.id;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox.shrink(); // أو أي عنصر تحميل مؤقت
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return SizedBox.shrink(); // تخطي إذا لم يتم العثور على المستخدم
                }

                final user = userSnapshot.data!;
                final userName = user['storeName'] ?? 'Unnamed User';

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .collection('chats')
                      .doc(userId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, lastMessageSnapshot) {
                    if (!lastMessageSnapshot.hasData || lastMessageSnapshot.data!.docs.isEmpty) {
                      return SizedBox.shrink(); // لا تعرض إذا لم توجد رسائل
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUserId)
                          .collection('chats')
                          .doc(userId)
                          .collection('messages')
                          .where('isRead', isEqualTo: false)
                          .where('receiverId', isEqualTo: currentUserId)
                          .snapshots(),
                      builder: (context, unreadMessagesSnapshot) {
                        int unreadCount = unreadMessagesSnapshot.data?.docs.length ?? 0;
                        String lastMessageTime = '';
                        String lastMessageText = 'لا توجد رسائل بعد';
                        bool isLastMessageRead = true;

                        if (lastMessageSnapshot.hasData &&
                            lastMessageSnapshot.data!.docs.isNotEmpty) {
                          final lastMessage = lastMessageSnapshot.data!.docs.first;
                          lastMessageText = lastMessage['text'] ?? 'رسالة بدون نص';
                          isLastMessageRead = lastMessage['isRead'] ?? true;
                          
                          if (lastMessage['imageUrl'] != null) {
                            lastMessageText = 'صورة';
                          } else if (lastMessage['audioUrl'] != null) {
                            lastMessageText = 'رسالة صوتية';
                          }
                          
                          Timestamp timestamp = lastMessage['timestamp'] ?? Timestamp.now();
                          DateTime messageTime = timestamp.toDate();
                          lastMessageTime = "${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}";
                        }

                        return Container(
                          margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: user['profileImage'] != null
                                    ? NetworkImage(user['profileImage'])
                                    : AssetImage('assets/images/5.jpg') as ImageProvider,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        CupertinoPageRoute(builder: (context) {
                                      return ChatRoom(userId: userId, userName: userName);
                                    }));
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                          fontFamily: 'Tajawal',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        lastMessageText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xff514D4D),
                                          fontSize: 14,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (unreadCount > 0)
                                    CircleAvatar(
                                      backgroundColor: MyTheme.kUnreadChatBG,
                                      radius: 12,
                                      child: Text(
                                        unreadCount > 99 ? '+99' : '$unreadCount',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.done_all_sharp,
                                      color: isLastMessageRead 
                                          ? MyColor.pinkColor 
                                          : Colors.grey,
                                    ),
                                  SizedBox(height: 10),
                                  Text(
                                    lastMessageTime, 
                                    style: MyTheme.bodyTextTime
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}