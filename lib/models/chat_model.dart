// models/chat_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class ChatMessage {
  final String? senderId;
  final String? receiverId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;
  final Timestamp? timestamp;
  final bool? isRead;

  ChatMessage({
    this.senderId,
    this.receiverId,
    this.text,
    this.imageUrl,
    this.audioUrl,
    this.timestamp,
    this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'isRead': isRead ?? false,
    };
  }
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  Future<void> sendMessage({
    required String receiverId,
    String? text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    final messageId = _firestore.collection('messages').doc().id;
    
    final messageData = ChatMessage(
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
    ).toMap();

    // Save in sender's chat
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);

    // Save in receiver's chat
    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(currentUserId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);
  }

  Future<String> uploadChatImage(File imageFile) async {
    final ref = _storage.ref('chats_images/${_uuid.v1()}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<String> uploadAudioFile(String filePath) async {
    final file = File(filePath);
    final ref = _storage.ref('voices/${_uuid.v1()}.m4a');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Stream<QuerySnapshot> getChatMessages(String userId, String otherUserId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(otherUserId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markMessagesAsRead(
      String userId, String otherUserId, List<String> messageIds) async {
    final batch = _firestore.batch();

    for (final messageId in messageIds) {
      final messageRef1 = _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(otherUserId)
          .collection('messages')
          .doc(messageId);

      final messageRef2 = _firestore
          .collection('users')
          .doc(otherUserId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .doc(messageId);

      batch.update(messageRef1, {'isRead': true});
      batch.update(messageRef2, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteMessages(
      String userId, String otherUserId, bool deleteForBoth) async {
    // Delete from current user
    final currentUserMessages = await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(otherUserId)
        .collection('messages')
        .get();

    final batch1 = _firestore.batch();
    for (var doc in currentUserMessages.docs) {
      batch1.delete(doc.reference);
    }
    await batch1.commit();

    // Delete from other user if requested
    if (deleteForBoth) {
      final otherUserMessages = await _firestore
          .collection('users')
          .doc(otherUserId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .get();

      final batch2 = _firestore.batch();
      for (var doc in otherUserMessages.docs) {
        batch2.delete(doc.reference);
      }
      await batch2.commit();
    }
  }
}