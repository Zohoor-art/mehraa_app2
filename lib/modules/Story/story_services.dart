import 'package:cloud_firestore/cloud_firestore.dart';

class StoryServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة مشاهدة للستوري
  static Future<void> addView(String storyId, String userId) async {
    try {
      final storyRef = _firestore.collection('stories').doc(storyId);
      final storySnapshot = await storyRef.get();
      if (!storySnapshot.exists) return;

      Map<String, dynamic> currentViews = {};

      if (storySnapshot.data()!['views'] != null) {
        currentViews = Map<String, dynamic>.from(storySnapshot.data()!['views']);
      }

      if (!currentViews.containsKey(userId)) {
        currentViews[userId] = true;
        await storyRef.update({'views': currentViews});
      }
    } catch (e) {
      print('❌ خطأ أثناء تسجيل المشاهدة: $e');
    }
  }

  // تبديل حالة اللايك (لايك / إلغاء لايك)
  static Future<void> toggleLike(String storyId, String userId) async {
    try {
      final storyRef = _firestore.collection('stories').doc(storyId);
      final storySnapshot = await storyRef.get();
      if (!storySnapshot.exists) return;

      Map<String, dynamic> currentLikes = {};

      if (storySnapshot.data()!['likes'] != null) {
        currentLikes = Map<String, dynamic>.from(storySnapshot.data()!['likes']);
      }

      if (currentLikes.containsKey(userId)) {
        // إلغاء لايك
        currentLikes.remove(userId);
      } else {
        // إضافة لايك
        currentLikes[userId] = true;
      }

      await storyRef.update({'likes': currentLikes});
    } catch (e) {
      print('❌ خطأ أثناء تسجيل اللايك: $e');
    }
  }

  // جلب عدد المشاهدات
  static Future<int> getViewCount(String storyId) async {
    try {
      final storySnapshot = await _firestore.collection('stories').doc(storyId).get();
      if (!storySnapshot.exists) return 0;

      final views = storySnapshot.data()!['views'];
      if (views == null) return 0;

      return (views as Map).length;
    } catch (e) {
      print('❌ خطأ أثناء جلب عدد المشاهدات: $e');
      return 0;
    }
  }

  // جلب عدد اللايكات
  static Future<int> getLikeCount(String storyId) async {
    try {
      final storySnapshot = await _firestore.collection('stories').doc(storyId).get();
      if (!storySnapshot.exists) return 0;

      final likes = storySnapshot.data()!['likes'];
      if (likes == null) return 0;

      return (likes as Map).length;
    } catch (e) {
      print('❌ خطأ أثناء جلب عدد اللايكات: $e');
      return 0;
    }
  }
}
