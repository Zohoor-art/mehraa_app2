import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  final String uid;
  final String postId;
  final String description;
  final Timestamp datePublished;
  final String postUrl;
  final String profileImage;
  final List<String> likes;
  final String storeName;
  final String videoUrl;
  final DocumentReference? userRef;
  final bool isDeleted;
  final Timestamp? deletedAt;
  final List<String> tags;
  final int commentCount;
  final int shareCount;
  final String location;
  final String? locationUrl; // ✅ الموقع المفصل
  final GeoPoint? locationCoords; // ✅ إحداثيات الموقع التلقائي
  final List<String> savedBy;
  final bool isVideo;

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
    this.userRef,
    this.isDeleted = false,
    this.deletedAt,
    this.tags = const [],
    this.commentCount = 0,
    this.shareCount = 0,
    this.location = '',
    this.locationUrl, // ✅
    this.locationCoords, // ✅
    this.savedBy = const [],
    this.isVideo = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      uid: json['uid'] ?? '',
      postId: json['postId'] ?? '',
      description: json['description'] ?? '',
      datePublished: json['datePublished'] ?? Timestamp.now(),
      postUrl: json['postUrl'] ?? '',
      profileImage: json['profileImage'] ?? '',
      likes: List<String>.from(json['likes'] ?? []),
      storeName: json['storeName'] ?? 'متجر غير معروف',
      videoUrl: json['videoUrl'] ?? '',
      userRef: json['userRef'],
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'],
      tags: List<String>.from(json['tags'] ?? []),
      commentCount: json['commentCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      location: json['location'] ?? '',
      locationUrl: json['locationUrl'], // ✅
      locationCoords: json['locationCoords'], // ✅ GeoPoint يأتي تلقائيًا
      savedBy: List<String>.from(json['savedBy'] ?? []),
      isVideo: json['isVideo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'postId': postId,
        'description': description,
        'datePublished': datePublished,
        'postUrl': postUrl,
        'profileImage': profileImage,
        'likes': likes,
        'storeName': storeName,
        'videoUrl': videoUrl,
        'userRef': userRef,
        'isDeleted': isDeleted,
        'deletedAt': deletedAt,
        'tags': tags,
        'commentCount': commentCount,
        'shareCount': shareCount,
        'location': location,
        'locationUrl': locationUrl, // ✅
        'locationCoords': locationCoords, // ✅
        'savedBy': savedBy,
        'isVideo': isVideo,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    final snapshot = snap.data() as Map<String, dynamic>;
    return Post.fromJson(snapshot);
  }

  Future<Map<String, dynamic>> getUserData() async {
    if (userRef == null) {
      return {
        'profileImage': profileImage,
        'storeName': storeName,
        'uid': uid,
      };
    }

    try {
      final userDoc = await userRef!.get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return {
          'profileImage': userData['profileImage'] ?? profileImage,
          'storeName': userData['storeName'] ?? storeName,
          'uid': userData['uid'] ?? uid,
        };
      }
      return {
        'profileImage': profileImage,
        'storeName': storeName,
        'uid': uid,
      };
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return {
        'profileImage': profileImage,
        'storeName': storeName,
        'uid': uid,
      };
    }
  }

  Post copyWith({
    String? uid,
    String? postId,
    String? description,
    Timestamp? datePublished,
    String? postUrl,
    String? profileImage,
    List<String>? likes,
    String? storeName,
    String? videoUrl,
    DocumentReference? userRef,
    bool? isDeleted,
    Timestamp? deletedAt,
    List<String>? tags,
    int? commentCount,
    int? shareCount,
    String? location,
    String? locationUrl, // ✅
    GeoPoint? locationCoords, // ✅
    List<String>? savedBy,
    bool? isVideo,
  }) {
    return Post(
      uid: uid ?? this.uid,
      postId: postId ?? this.postId,
      description: description ?? this.description,
      datePublished: datePublished ?? this.datePublished,
      postUrl: postUrl ?? this.postUrl,
      profileImage: profileImage ?? this.profileImage,
      likes: likes ?? this.likes,
      storeName: storeName ?? this.storeName,
      videoUrl: videoUrl ?? this.videoUrl,
      userRef: userRef ?? this.userRef,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      tags: tags ?? this.tags,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      location: location ?? this.location,
      locationUrl: locationUrl ?? this.locationUrl,
      locationCoords: locationCoords ?? this.locationCoords,
      savedBy: savedBy ?? this.savedBy,
      isVideo: isVideo ?? this.isVideo,
    );
  }

  String get mediaUrl => isVideo ? videoUrl : postUrl;
}