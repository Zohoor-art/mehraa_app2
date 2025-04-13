import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/firebase/storge.dart';
import 'package:mehra_app/models/post.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/material.dart'; // استيراد المكتبة

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String storename,
    String profileImage, {
    String? videoPath,
    required BuildContext context, // إضافة BuildContext هنا
  }) async {
    String res = "ظهر خطأ ما";
    try {
      String postId = Uuid().v1(); // Generate a unique post ID

      // Upload image if available
      String? photoURL;
      if (file.isNotEmpty) {
        photoURL = await StorageMethod().uploadImageToStorage('posts', file, true);
      }

      // Upload video if available
      String? videoURL;
      if (videoPath != null && videoPath.isNotEmpty) {
        videoURL = await StorageMethod().uploadVideoToStorage('posts/videos', File(videoPath));
      }

      Post post = Post(
        description: description,
        uid: uid,
        storeName: storename,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoURL ?? '', // Use photo URL if available
        videoUrl: videoURL ?? '', // Add video URL
        profileImage: profileImage,
        likes: [],
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "تم نشر الصورة والفيديو بنجاح";

      // عرض رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));

    } catch (e) {
      res = e.toString();
      // عرض رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
    return res;
  }
}