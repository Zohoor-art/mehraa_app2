import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/userModel.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد إشعارات حالياً'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final data = notif.data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(data['fromUid'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox();

                  final user = Users.fromSnap(userSnapshot.data!);

                  String actionText;
                  switch (data['type']) {
                    case 'like':
                      actionText = 'أعجب بمنشورك';
                      break;
                    case 'comment':
                      actionText = 'علق على منشورك';
                      break;
                    case 'follow':
                      actionText = 'بدأ بمتابعتك';
                      break;
                    default:
                      actionText = 'قام بإجراء ما';
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.profileImage ?? ''),
                    ),
                    title: Text(
                      user.storeName.isNotEmpty
                          ? user.storeName
                          : user.email ?? 'مستخدم',
                    ),
                    subtitle: Text(actionText),
                    trailing: Text(timeAgo(data['timestamp'])),
                    onTap: () {
                      // يمكن مستقبلاً التنقل إلى المنشور أو البروفايل حسب نوع الإشعار
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

  String timeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'الآن';
    if (difference.inMinutes < 60) return '${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return '${difference.inHours} ساعة';
    if (difference.inDays < 7) return '${difference.inDays} يوم';
    return '${date.day}/${date.month}/${date.year}';
  }
}
