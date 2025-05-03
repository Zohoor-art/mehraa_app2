import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type; // like, comment, follow
  final String senderId;
  final String senderName;
  final String senderProfileImage;
  final String? postId;
  final String? postImage;
  final String receiverId;
  final String? commentText;
  final Timestamp timestamp;

  AppNotification({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.senderProfileImage,
    required this.receiverId,
    this.postId,
    this.postImage,
    this.commentText,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'senderId': senderId,
        'senderName': senderName,
        'senderProfileImage': senderProfileImage,
        'receiverId': receiverId,
        'postId': postId,
        'postImage': postImage,
        'commentText': commentText,
        'timestamp': timestamp,
      };

  factory AppNotification.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return AppNotification(
      id: data['id'],
      type: data['type'],
      senderId: data['senderId'],
      senderName: data['senderName'],
      senderProfileImage: data['senderProfileImage'],
      receiverId: data['receiverId'],
      postId: data['postId'],
      postImage: data['postImage'],
      commentText: data['commentText'],
      timestamp: data['timestamp'],
    );
  }
}
