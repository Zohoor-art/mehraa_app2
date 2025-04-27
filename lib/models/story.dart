import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String mediaUrl;
  final String mediaType;
  final String userId;
  final Timestamp timestamp;
  final String? caption;
  final String? profileImageUrl;

  Story({
    required this.mediaUrl,
    required this.mediaType,
    required this.userId,
    required this.timestamp,
    this.caption,
    this.profileImageUrl,
  });

  factory Story.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw StateError('📛 المستند لا يحتوي على بيانات!');

    return Story(
      mediaUrl: (data['mediaUrl'] ?? '').toString().trim(),
      mediaType: (data['mediaType'] ?? 'image').toString().trim(),
      userId: (data['userId'] ?? '').toString().trim(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      caption: (data['caption'] ?? '').toString().trim(),
      profileImageUrl: (data['profileImageUrl'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'userId': userId,
      'timestamp': timestamp,
      'caption': caption,
      'profileImageUrl': profileImageUrl,
    };
  }
}
