import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String postId;
  final String description;
  final DateTime datePublished;
  final String postUrl;
  final String profileImage;
  final List<dynamic> likes;
  final String storeName;
  final String videoUrl;

  const Post({
    required this.uid,
    required this.postId,
    required this.description,
    required this.datePublished,
    required this.postUrl,
    required this.profileImage,
    required this.likes,
    required this.storeName,
    required this.videoUrl,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'postId': postId,
        'description': description,
        'postUrl': postUrl,
        'profileImage': profileImage,
        'datePublished': datePublished,
        'likes': likes,
        'storeName': storeName,
        'videoUrl': videoUrl,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      uid: snapshot['uid'],
      postId: snapshot['postId'],
      description: snapshot['description'],
      postUrl: snapshot['postUrl'],
      profileImage: snapshot['profileImage'],
      datePublished: (snapshot['datePublished'] as Timestamp).toDate(),
      likes: List.from(snapshot['likes']),
      storeName: snapshot['storeName'],
      videoUrl: snapshot['videoUrl'] ?? '',
    );
  }
}
