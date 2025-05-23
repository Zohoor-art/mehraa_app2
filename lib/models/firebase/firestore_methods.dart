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
  required bool isVideo,
  DocumentReference? userRef,
  required BuildContext context,
  required String location,
  String? locationUrl,
  GeoPoint? locationCoords,
}) async {
  String res = "ظهر خطأ ما";
  try {
    String postId = const Uuid().v1();

    String? photoUrl;
    if (file.isNotEmpty) {
      photoUrl = await StorageMethod().uploadImageToStorage('posts', file, true);
    }

    String? videoUrl;
    if (videoPath != null && videoPath.isNotEmpty) {
      videoUrl = await StorageMethod().uploadVideoToStorage('posts/videos', File(videoPath));
    }

    Timestamp datePublished = Timestamp.now();

    // ✅ جلب workType فقط من المستخدم (بدون حساب التقييم)
    String? workType;
    if (userRef != null) {
      final userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        workType = userSnapshot.get('workType');
      }
    }

    Map<String, dynamic> postData = {
      'uid': uid,
      'postId': postId,
      'description': description,
      'datePublished': datePublished,
      'postUrl': photoUrl ?? '',
      'videoUrl': videoUrl ?? '',
      'profileImage': profileImage,
      'storeName': storename,
      'likes': [],
      'userRef': userRef,
      'isVideo': isVideo,
      'location': location,
      'locationUrl': locationUrl,
      'locationCoords': locationCoords,
      'workType': workType,
    };

    postData.removeWhere((key, value) => value == null || value == '');

    await FirebaseFirestore.instance.collection('posts').doc(postId).set(postData);

    res = 'تم نشر الصورة بنجاح';
  } on FirebaseException catch (e) {
    res = e.message ?? 'حدث خطأ أثناء النشر';
  } catch (e) {
    res = e.toString();
  }
  return res;
}
}