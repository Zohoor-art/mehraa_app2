import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String toUid;
  final String fromUid;
  final String type; // like, comment, follow, rating, order, weeklyReport
  final String? postId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.toUid,
    required this.fromUid,
    required this.type,
    this.postId,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  factory AppNotification.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // توليد الرسالة بناءً على النوع
    String generatedMessage;
    switch (data['type']) {
      case 'like':
        generatedMessage = 'أعجب بمنشورك';
        break;
      case 'comment':
        generatedMessage = 'علق على منشورك';
        break;
      case 'share':
        generatedMessage = 'شارك منشورك';
        break;
      case 'follow':
        generatedMessage = 'بدأ بمتابعتك';
        break;
      case 'rating':
        generatedMessage = 'قام بتقييم متجرك🎉';
        break;
      case 'order':
        generatedMessage = 'تم طلب أحد منتجاتك 🛒';
        break;
     case 'weeklySummary':

        generatedMessage = data['message'] ?? 'تقريرك الأسبوعي جاهز 📊';
        break;
      default:
        generatedMessage = 'لديك إشعار جديد';
    }

    return AppNotification(
      id: doc.id,
      toUid: data['toUid'] ?? '',
      fromUid: data['fromUid'] ?? '',
      type: data['type'] ?? '',
      postId: data['postId'],
      message: generatedMessage,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }
}
