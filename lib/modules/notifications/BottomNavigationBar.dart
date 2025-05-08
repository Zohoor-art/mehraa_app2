// import 'package:badges/badges.dart' as badges;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// // زر الإشعارات في شريط التنقل
// Widget notificationIcon() {
//   final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//   if (currentUserId == null) {
//     return const Icon(Icons.notifications);
//   }

//   return StreamBuilder<QuerySnapshot>(
//     stream: FirebaseFirestore.instance
//         .collection('notifications')
//         .where('receiverId', isEqualTo: currentUserId)
//         .where('isRead', isEqualTo: false)
//         .snapshots(),
//     builder: (context, snapshot) {
//       final hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

//       return badges.Badge(
//         position: badges.BadgePosition.topEnd(top: -4, end: -4),
//         showBadge: hasUnread,
//         badgeStyle: const badges.BadgeStyle(
//           badgeColor: Colors.red,
//         ),
//         badgeContent: const SizedBox(
//           width: 8,
//           height: 8,
//         ),
//         child: const Icon(Icons.notifications),
//       );
//     },
//   );
// }
