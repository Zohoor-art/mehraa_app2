import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationMethods {
  static Future<void> sendLikeNotification({
    required String fromUid,
    required String toUid,
    required String postId,
    required String postImage,
  }) async {
    if (fromUid == toUid) return;

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(toUid)
        .collection('items')
        .add({
      'type': 'like',
      'fromUid': fromUid,
      'toUid': toUid,
      'postId': postId,
      'postImage': postImage,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  static Future<void> sendCommentNotification({
    required String fromUid,
    required String toUid,
    required String postId,
    required String postImage,
  }) async {
    if (fromUid == toUid) return;

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(toUid)
        .collection('items')
        .add({
      'type': 'comment',
      'fromUid': fromUid,
      'toUid': toUid,
      'postId': postId,
      'postImage': postImage,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  static Future<void> sendShareNotification({
    required String fromUid,
    required String toUid,
    required String postId,
    required String postImage,
  }) async {
    if (fromUid == toUid) return;

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(toUid)
        .collection('items')
        .add({
      'type': 'share',
      'fromUid': fromUid,
      'toUid': toUid,
      'postId': postId,
      'postImage': postImage,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  static Future<void> sendFollowNotification({
    required String fromUid,
    required String toUid,
  }) async {
    if (fromUid == toUid) return;

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(toUid)
        .collection('items')
        .add({
      'type': 'follow',
      'fromUid': fromUid,
      'toUid': toUid,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

static Future<void> sendWeeklySummaryNotification({
  required String toUid,
  required String message,
}) async {
  await FirebaseFirestore.instance
      .collection('notifications')
      .doc(toUid)
      .collection('items')
      .add({
    'type': 'weeklySummary',
    'toUid': toUid,
    'message': message,
    'timestamp': FieldValue.serverTimestamp(),
    'isRead': false,
  });
}
static Future<void> sendOrderNotification({
  required String fromUid,
  required String toUid,
  required String postId,
  required String postImage,
}) async {
  if (fromUid == toUid) return;

  await FirebaseFirestore.instance
      .collection('notifications')
      .doc(toUid)
      .collection('items')
      .add({
    'type': 'order',
    'fromUid': fromUid,
    'toUid': toUid,
    'postId': postId,
    'postImage': postImage,
    'timestamp': FieldValue.serverTimestamp(),
    'isRead': false,
  });
}
static Future<void> sendRatingNotification({
  required String fromUid,
  required String toUid,
}) async {
  if (fromUid == toUid) return;

  await FirebaseFirestore.instance
      .collection('notifications')
      .doc(toUid)
      .collection('items')
      .add({
    'type': 'rating',
    'fromUid': fromUid,
    'toUid': toUid,
    'timestamp': FieldValue.serverTimestamp(),
    'isRead': false,
  });
}
}