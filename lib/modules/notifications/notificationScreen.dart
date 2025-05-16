import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/notifications.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/homePage/post.dart';
import 'package:mehra_app/modules/notifications/NotificationItem.dart';
import 'package:mehra_app/modules/notifications/analitices_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> _notificationsFuture;
  Map<String, bool> _followStatus = {};

  @override
  void initState() {
    super.initState();
    _notificationsFuture = fetchNotifications();
  }

  Future<List<AppNotification>> fetchNotifications() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(currentUser.uid)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'follow') {
        _followStatus[doc.id] = data['isFollowed'] ?? false;
      }
    }

    return snapshot.docs
        .map((doc) => AppNotification.fromDocument(doc))
        .toList();
  }

  Future<bool> checkIfFollowing(String currentUserId, String otherUserId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .collection('followers')
        .doc(currentUserId)
        .get();

    return doc.exists;
  }

  Future<void> _handleFollowBack(String notificationId, String fromUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final batch = FirebaseFirestore.instance.batch();

    // أضف currentUserId كمُتابع للمستخدم fromUserId (followers)
    final followerDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(fromUserId)
        .collection('followers')
        .doc(currentUserId);

    batch.set(followerDoc, {});

    // أضف fromUserId كمُتابع لـ currentUserId (following)
    final followingDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(fromUserId);

    batch.set(followingDoc, {});

    // حدّث حالة isFollowed في إشعارات المستخدم
    final notificationDoc = FirebaseFirestore.instance
        .collection('notifications')
        .doc(currentUserId)
        .collection('items')
        .doc(notificationId);

    batch.update(notificationDoc, {'isFollowed': true});

    await batch.commit();

    setState(() {
      _followStatus[notificationId] = true;
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} يوم';
    return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد إشعارات.'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              final isSystem = [
                'weeklySummary',
                'topRated',
                'mostOrdered',
              ].contains(notification.type);

              final useNetworkImage = [
                'order',
                'rating',
              ].contains(notification.type);

             if (isSystem) {
  String displayMessage = 'لديك إشعار جديد';
  String avatarUrl = 'assets/2.png'; // تأكد أنك أضفت صورة مناسبة في assets
  String title = 'تحليلات الأسبوع';

  if (notification.type == 'weeklySummary') {
    displayMessage = 'إليك ملخص أداءك لهذا الأسبوع!';
    title = 'تحليلات الأسبوع';
  } else if (notification.type == 'topRated') {
    displayMessage = 'أنت من أعلى المتاجر تقييمًا هذا الأسبوع!';
    title = 'أفضل المتاجر';
  } else if (notification.type == 'mostOrdered') {
    displayMessage = 'منتجاتك من الأكثر طلبًا!';
    title = 'المنتجات الأكثر طلبًا';
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalyticsNotificationScreen(
            title: title,
            message: notification.message,
          ),
        ),
      );
    },
    child: NotificationItem(
      username: 'فريق مهرة',
      action: displayMessage,
      time: _formatTimeAgo(notification.timestamp),
      avatarUrl: avatarUrl,
      postImage: null,
      showButton: false,
      isSystemNotification: true,
      isImageFromNetwork: false,
      isFollowed: false,
      onFollowBackPressed: null,
    ),
  );
}


              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(notification.fromUid)
                    .get(),
                builder: (context, userSnapshot) {
                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;

                  final username = userData?['storeName'] ?? 'مستخدم';
                  final photoUrl = userData?['profileImage'] ?? 'assets/1.png';

                  return FutureBuilder<bool>(
                    future: notification.type == 'follow'
                        ? checkIfFollowing(
                            FirebaseAuth.instance.currentUser!.uid,
                            notification.fromUid)
                        : Future.value(false),
                    builder: (context, snapshotFollowing) {
                      final isAlreadyFollowing = snapshotFollowing.data ?? false;
                      final isFollowedInNotification =
                          _followStatus[notification.id] ?? false;

                      // إظهار زر الرد فقط إذا نوع الإشعار follow و
                      // المستخدم غير متابع مسبقًا و
                      // لم يتم الرد من قبل
                      final showReplyButton = notification.type == 'follow' &&
                          !isAlreadyFollowing &&
                          !isFollowedInNotification;

                      return FutureBuilder<DocumentSnapshot?>(
                        future: notification.postId != null
                            ? FirebaseFirestore.instance
                                .collection('posts')
                                .doc(notification.postId)
                                .get()
                            : Future.value(null),
                        builder: (context, postSnapshot) {
                          String? postImageUrl;
                          if (postSnapshot.hasData && postSnapshot.data!.exists) {
                            final postData =
                                postSnapshot.data!.data() as Map<String, dynamic>;
                            postImageUrl = postData['postUrl'];
                          }

                          return GestureDetector(
                            onTap: () async {
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;

                              await FirebaseFirestore.instance
                                  .collection('notifications')
                                  .doc(currentUser!.uid)
                                  .collection('items')
                                  .doc(notification.id)
                                  .update({'isRead': true});

                              switch (notification.type) {
                                case 'follow':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProfileScreen(userId: notification.fromUid),
                                    ),
                                  );
                                  break;

                                case 'comment':
                                case 'like':
                                case 'share':
                                  if (notification.postId != null) {
                                    final postDoc = await FirebaseFirestore
                                        .instance
                                        .collection('posts')
                                        .doc(notification.postId)
                                        .get();
                                    if (postDoc.exists) {
                                      final post = Post.fromSnap(postDoc);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PostWidget(
                                            post: post,
                                            currentUserId: currentUser.uid,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('المنشور غير موجود')),
                                      );
                                    }
                                  }
                                  break;

                                case 'order':
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('لديك طلب جديد!')),
                                  );
                                  break;

                                case 'rating':
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('تم تقييمك: ${notification.message}')),
                                  );
                                  break;
                              }
                            },
                            child: NotificationItem(
                              username: username,
                              action: notification.message,
                              time: _formatTimeAgo(notification.timestamp),
                              avatarUrl: photoUrl,
                              postImage: postImageUrl,
                              showButton: showReplyButton,
                              isSystemNotification: false,
                              isImageFromNetwork: useNetworkImage,
                              isFollowed: isFollowedInNotification || isAlreadyFollowing,
                              onFollowBackPressed: showReplyButton
                                  ? () => _handleFollowBack(
                                        notification.id,
                                        notification.fromUid,
                                      )
                                  : null,
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
      ),
    );
  }
}
