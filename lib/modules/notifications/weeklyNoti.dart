import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_methods.dart';

class WeeklyNotificationManager {
  static Future<bool> isWeeklyNotificationSent(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'weeklySummarySent_$storeId';

    final lastSent = prefs.getString(key);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    if (lastSent != null) {
      final lastDate = DateTime.tryParse(lastSent);
      if (lastDate != null && lastDate.isAfter(weekStart)) {
        return true;
      }
    }
    return false;
  }

  static Future<void> trySendWeeklySummaryIfNeeded(String storeId) async {
    final now = DateTime.now();
    if (now.weekday != DateTime.friday) return; // فقط يوم الجمعة

    final sent = await isWeeklyNotificationSent(storeId);
    if (sent) return;

    final ratingsRef = FirebaseFirestore.instance.collection('storeRatings').doc(storeId);
    final ordersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(storeId)
        .collection('orders');

    final nowDate = DateTime.now();
    final thisWeekStart = nowDate.subtract(Duration(days: nowDate.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(Duration(days: 7));

    final ratingsDoc = await ratingsRef.get();
    if (!ratingsDoc.exists) return;

    final data = ratingsDoc.data()!;
    final currentAvg = data['averageRating'] ?? 0;
    final currentTotal = data['totalRatings'] ?? 0;
    final currentPQ = data['productQuality'] ?? 0;
    final currentIS = data['interactionStyle'] ?? 0;
    final currentC = data['commitment'] ?? 0;

    // الطلبات هذا الأسبوع
    final thisWeekOrders = await ordersRef
        .where('createdAt', isGreaterThanOrEqualTo: thisWeekStart)
        .get();
    final ordersCount = thisWeekOrders.size;

    // التقييمات لهذا الأسبوع فقط (من كولكشن ratings)
    final ratersSnap = await ratingsRef.collection('ratings')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(thisWeekStart))
        .get();

    int pq = 0, istyle = 0, com = 0;
    for (var doc in ratersSnap.docs) {
      final d = doc.data();
      pq += int.tryParse(d['productQuality'].toString()) ?? 0;
      istyle += int.tryParse(d['interactionStyle'].toString()) ?? 0;
      com += int.tryParse(d['commitment'].toString()) ?? 0;
    }

    final count = ratersSnap.size;

    String message;
    if (count == 0) {
      message = '📊 لم تحصل على تقييمات هذا الأسبوع.\n'
          '✨ حاول تشجيع العملاء على تقييم خدماتك.\n'
          '🛒 الطلبات: $ordersCount';
    } else {
      final avgThisWeek = ((pq + istyle + com) / (3 * count)).round();
      String topAspect;
      int topValue = [pq, istyle, com].reduce((a, b) => a > b ? a : b);
      if (topValue == pq) topAspect = 'جودة المنتج';
      else if (topValue == istyle) topAspect = 'أسلوب التعامل';
      else topAspect = 'الالتزام بالمواعيد';

      // مقارنة بين التقييم الأسبوعي والكلي
      String motivational;
      if (avgThisWeek > currentAvg) {
        motivational = '🚀 تقدم رائع هذا الأسبوع! استمر! 💪';
      } else if (avgThisWeek < currentAvg) {
        motivational = '📉 حصل انخفاض بسيط، حاول تحسين تجربتك الأسبوع القادم.';
      } else {
        motivational = '📊 تقييمك ثابت هذا الأسبوع، ممتاز! ✨';
      }

      message = '📊 ملخص أسبوعي:\n'
          '⭐ متوسط تقييم هذا الأسبوع: $avgThisWeek\n'
          '🏅 أعلى نقطة في: $topAspect\n'
          '🛒 الطلبات: $ordersCount\n'
          '$motivational';
    }

    await NotificationMethods.sendWeeklySummaryNotification(
      toUid: storeId,
      message: message,
    );

    final prefs = await SharedPreferences.getInstance();
    final key = 'weeklySummarySent_$storeId';
    await prefs.setString(key, DateTime.now().toIso8601String());
  }
}
