import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  /// إرسال إشعار عام
  static Future<void> sendNotification({
    required String toUid,
    required String fromUid,
    required String type, // like, comment, follow, rating, order...
    String? postId,
    required String message,
  }) async {
    if (toUid == fromUid) return; // لا ترسل إشعار لنفسك

    await FirebaseFirestore.instance.collection('notifications').add({
      'toUid': toUid,
      'fromUid': fromUid,
      'type': type,
      'postId': postId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// إشعار مخصص لتقرير الأسبوع من النظام
  // static Future<void> sendWeeklyReportNotification({
  //   required String toUid,
  //   required String reportMessage,
  // }) async {
  //   await FirebaseFirestore.instance.collection('notifications').add({
  //     'toUid': toUid,
  //     'fromUid': 'system',
  //     'type': 'weeklyReport',
  //     'message': reportMessage,
  //     'timestamp': FieldValue.serverTimestamp(),
  //     'isRead': false,
  //   });
  // }
}
