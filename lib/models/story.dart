import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // لإضافة دعم لألوان Material

class Story {
  final String storyId;
  final String userId;
  final String mediaUrl;
  final String mediaType; // 'image', 'video', or 'text'
  final String? caption;
  final bool isOpened;
  final DateTime timestamp;
  final Map<String, dynamic>? views;
  final Map<String, dynamic>? likes;
  final int? backgroundColor; // ✅ جديد: لون الخلفية (يتم تخزينه كقيمة int)

  Story({
    required this.storyId,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    this.isOpened = false,
    required this.timestamp,
    this.views,
    this.likes,
    this.backgroundColor, // ✅ جديد: معامل اختياري
  });

  // الحصول على لون الخلفية ككائن Color
  Color get backgroundAsColor {
    return backgroundColor != null 
        ? Color(backgroundColor!) 
        : Colors.deepPurple; // لون افتراضي
  }

  factory Story.fromDocumentSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Story(
      storyId: snap.id,
      userId: data['userId'],
      mediaUrl: data['mediaUrl'],
      mediaType: data['mediaType'] ?? 'image',
      caption: data['caption'],
      isOpened: data['isOpened'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      views: (data['views'] != null) ? Map<String, dynamic>.from(data['views']) : {},
      likes: (data['likes'] != null) ? Map<String, dynamic>.from(data['likes']) : {},
      backgroundColor: data['backgroundColor'], // ✅ جديد: قراءة لون الخلفية
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'isOpened': isOpened,
      'timestamp': Timestamp.fromDate(timestamp),
      'views': views ?? {},
      'likes': likes ?? {},
      'backgroundColor': backgroundColor, // ✅ جديد: حفظ لون الخلفية
    };
  }
}