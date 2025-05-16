import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/theme/theme.dart';
import 'chat_room.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RecentChats extends StatelessWidget {
  final String searchQuery;

  const RecentChats({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
        );
        Navigator.of(context).pushReplacementNamed('/register');
      });
      return const SizedBox();
    }

    final currentUserId = currentUser.uid;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getFilteredChats(currentUserId, searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }

        final filteredChats = snapshot.data ?? [];

        if (filteredChats.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty ? 'لا توجد محادثات حالية' : 'لا توجد نتائج بحث',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chatData = filteredChats[index];
            return _ChatListItem(
              currentUserId: currentUserId,
              userId: chatData['uid'],
              userName: chatData['displayName'] ?? chatData['storeName'] ?? 'بدون اسم',
              userProfileImage: chatData['profileImage'],
              isCommercial: chatData['isCommercial'] ?? false,
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getFilteredChats(String currentUserId, String query) async {
    final chatSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .get();

    final chatDocs = chatSnapshot.docs;

    final List<Map<String, dynamic>> result = [];
    for (final chatDoc in chatDocs) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(chatDoc.id)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        
        if (query.isEmpty || _matchesSearchQuery(userData, query)) {
          result.add({
            'uid': userDoc.id,
            ...userData,
          });
        }
      }
    }
    return result;
  }

  bool _matchesSearchQuery(Map<String, dynamic> userData, String query) {
    final storeName = (userData['storeName'] ?? '').toString().toLowerCase();
    final displayName = (userData['displayName'] ?? '').toString().toLowerCase();
    final searchQuery = query.toLowerCase();
    
    return storeName.contains(searchQuery) || displayName.contains(searchQuery);
  }
}

class _ChatListItem extends StatefulWidget {
  final String currentUserId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final bool isCommercial;

  const _ChatListItem({
    Key? key,
    required this.currentUserId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.isCommercial,
  }) : super(key: key);

  @override
  State<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<_ChatListItem> with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.2,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('chats')
        .doc(widget.userId)
        .collection('messages');

    return StreamBuilder<QuerySnapshot>(
      stream: messagesRef.orderBy('timestamp', descending: true).limit(1).snapshots(),
      builder: (context, lastMessageSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: messagesRef
              .where('isRead', isEqualTo: false)
              .where('receiverId', isEqualTo: widget.currentUserId)
              .snapshots(),
          builder: (context, unreadMessagesSnapshot) {
            final unreadCount = unreadMessagesSnapshot.data?.docs.length ?? 0;
            final messageData = _getLastMessageData(lastMessageSnapshot);

            return Slidable(
              key: ValueKey(widget.userId),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _deleteChat(context),
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                    label: 'حذف',
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                child: Row(
                  children: [
                    _buildUserAvatar(),
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToChatRoom(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              messageData.text,
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
                    _buildMessageStatus(unreadCount, messageData),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[300],
          backgroundImage: widget.userProfileImage != null && widget.userProfileImage!.isNotEmpty
              ? CachedNetworkImageProvider(widget.userProfileImage!)
              : const AssetImage('assets/images/profile.jpg') as ImageProvider,
        ),
        if (widget.isCommercial)
          Positioned(
            bottom: -2,
            right: -2,
            child: ScaleTransition(
              scale: _iconAnimationController,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [MyColor.purpleColor, MyColor.blueColor],
                  ),
                ),
                child: const Icon(Icons.storefront, color: Colors.white, size: 14),
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToChatRoom(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ChatRoom(userId: widget.userId, userName: widget.userName),
      ),
    );
  }

  void _deleteChat(BuildContext context) async {
    final chatRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('chats')
        .doc(widget.userId);

    final messages = await chatRef.collection('messages').get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    await chatRef.delete();
  }

  Widget _buildMessageStatus(int unreadCount, LastMessageData messageData) {
    Color iconColor = messageData.isRead ? MyColor.pinkColor : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (unreadCount > 0)
          CircleAvatar(
            backgroundColor: MyTheme.kUnreadChatBG,
            radius: 12,
            child: Text(
              unreadCount > 99 ? '99+' : '$unreadCount',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Icon(
            Icons.done_all_sharp,
            color: iconColor,
          ),
        const SizedBox(height: 10),
        Text(
          messageData.time,
          style: MyTheme.bodyTextTime,
        ),
      ],
    );
  }

  LastMessageData _getLastMessageData(AsyncSnapshot<QuerySnapshot> snapshot) {
    String text = 'لا توجد رسائل بعد';
    String time = '';
    bool isRead = true;
    bool isSentByMe = false;

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      final lastMessage = snapshot.data!.docs.first;
      final data = lastMessage.data() as Map<String, dynamic>? ?? {};

      if (data['imageUrl'] != null) {
        text = 'صورة';
      } else if (data['audioUrl'] != null) {
        text = 'رسالة صوتية';
      } else if (data.containsKey('text')) {
        text = data['text'] ?? 'رسالة بدون نص';
      } else {
        text = 'طلب';
      }

      isRead = data['isRead'] ?? true;
      isSentByMe = data['senderId'] == widget.currentUserId;

      final timestamp = data['timestamp'] as Timestamp? ?? Timestamp.now();
      final messageTime = timestamp.toDate();
      time = "${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}";
    }

    return LastMessageData(text, time, isRead, isSentByMe);
  }
}

class LastMessageData {
  final String text;
  final String time;
  final bool isRead;
  final bool isSentByMe;

  LastMessageData(this.text, this.time, this.isRead, this.isSentByMe);
}