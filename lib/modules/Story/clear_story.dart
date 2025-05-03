import 'package:cloud_firestore/cloud_firestore.dart';

class StoryCleaner {
  static Future<void> cleanExpiredStories() async {
    final now = Timestamp.now();
    final storiesSnapshot = await FirebaseFirestore.instance
        .collection('stories')
        .get();

    for (var doc in storiesSnapshot.docs) {
      final data = doc.data();
      final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();

      final storyTime = timestamp.toDate();
      if (DateTime.now().difference(storyTime).inHours >= 24) {
        // حذف الاستوري اللي انتهى
        await FirebaseFirestore.instance.collection('stories').doc(doc.id).delete();
        print('🗑️ تم حذف ستوري قديم: ${doc.id}');
      }
    }
  }
}
