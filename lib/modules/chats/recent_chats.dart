import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/theme/theme.dart';
import 'chat_room.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({super.key});

  // دالة لحذف المحادثة
  Future<void> _deleteChat(String currentUserId, String userId) async {
    try {
      // حذف جميع الرسائل من محادثة المستخدم الحالي مع المستخدم الآخر
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // حذف وثيقة المحادثة نفسها
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(userId)
          .delete();
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data!.docs;
        return ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userName = user['storeName'] ?? 'Unnamed User';
            final userId = user.id;
            
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
                  return SizedBox.shrink();
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

                    return Slidable(
                      key: ValueKey(userId),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              await _deleteChat(currentUserId, userId);
                            },
                            backgroundColor: MyColor.purpleColor,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'حذف',
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)
                        ),
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
  }
}