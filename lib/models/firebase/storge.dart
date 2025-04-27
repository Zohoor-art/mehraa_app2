import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class StorageMethod {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(String name, Uint8List file, bool isPost) async {
    // تحقق من وجود المستخدم
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently signed in.");
    }

    Reference ref = _storage.ref().child(name).child(currentUser.uid);
    if (isPost) {
      String id = Uuid().v1();
      ref = ref.child(id);
    }

    try {
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // معالجة الأخطاء
      debugPrint("Error uploading image: $e");
      throw Exception("Failed to upload image: $e");
    }
  }

  Future<String> uploadVideoToStorage(String path, File video) async {
    // تحقق من وجود المستخدم
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently signed in.");
    }

    Reference ref = _storage.ref().child(path).child(currentUser.uid).child(video.path.split('/').last);

    try {
      UploadTask uploadTask = ref.putFile(video);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // معالجة الأخطاء
      debugPrint("Error uploading video: $e");
      throw Exception("Failed to upload video: $e");
    }
  }
    Future<String> uploadChatImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance.ref('chats_images/${Uuid().v1()}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      final ref = FirebaseStorage.instance.ref('voices/${Uuid().v1()}.m4a');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload audio: $e');
    }
  }
}