import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/post.dart';

class Reel {
  final String postId;
  final String uid;
  final String videoUrl;
  final String description;
  final String storeName;
  final String profileImage;
  final String location;
  final Timestamp datePublished;
  final List<String> likes;
  final int commentCount;
  final String? audioName; // يمكن إضافته إذا كان لديك بيانات الصوت
  
  const Reel({
    required this.postId,
    required this.uid,
    required this.videoUrl,
    required this.description,
    required this.storeName,
    required this.profileImage,
    required this.location,
    required this.datePublished,
    required this.likes,
    required this.commentCount,
    this.audioName,
  });

  // تحويل من Post إلى Reel
  factory Reel.fromPost(Post post) {
    return Reel(
      postId: post.postId,
      uid: post.uid,
      videoUrl: post.videoUrl,
      description: post.description,
      storeName: post.storeName,
      profileImage: post.profileImage,
      location: post.location,
      datePublished: post.datePublished,
      likes: post.likes,
      commentCount: post.commentCount,
    );
  }

  // تحويل من DocumentSnapshot إلى Reel
  factory Reel.fromSnapshot(DocumentSnapshot snap) {
    final snapshot = snap.data() as Map<String, dynamic>;
    return Reel(
      postId: snapshot['postId'] ?? '',
      uid: snapshot['uid'] ?? '',
      videoUrl: snapshot['videoUrl'] ?? '',
      description: snapshot['description'] ?? '',
      storeName: snapshot['storeName'] ?? 'متجر غير معروف',
      profileImage: snapshot['profileImage'] ?? '',
      location: snapshot['location'] ?? '',
      datePublished: snapshot['datePublished'] ?? Timestamp.now(),
      likes: List<String>.from(snapshot['likes'] ?? []),
      commentCount: snapshot['commentCount']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'videoUrl': videoUrl,
      'description': description,
      'storeName': storeName,
      'profileImage': profileImage,
      'location': location,
      'datePublished': datePublished,
      'likes': likes,
      'commentCount': commentCount,
      if (audioName != null) 'audioName': audioName,
    };
  }

  // إحصائيات الـ Reel (يمكن استخدامها في واجهة المستخدم)
  String get likesCount => _formatCount(likes.length);
  String get commentsCount => _formatCount(commentCount);

  static String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}