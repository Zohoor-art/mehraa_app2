import 'package:cloud_firestore/cloud_firestore.dart';

class SearchUtils {
  static Future<List<Map<String, dynamic>>> searchUsers({
    required String currentUserId,
    required String searchQuery,
  }) async {
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .get();

    final allUsers = usersSnap.docs
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();

    return allUsers.where((user) {
      final storeName = (user['storeName'] ?? '').toLowerCase();
      final displayName = (user['displayName'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      return storeName.contains(query) || displayName.contains(query);
    }).toList();
  }
}