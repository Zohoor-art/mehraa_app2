import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mehra_app/models/chat_model.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/shared/utils/exception.dart';
import 'package:uuid/uuid.dart';

class Firebase_Firestor {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // دوال المستخدمين
  Future<bool> CreateUser({
    required String contactNumber,
    required String days,
    required String description,
    required String email,
    required String hours,
    required String location,
    String? profileImage,
    required String storeName,
    required String workType,
  }) async {
    await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'contactNumber': contactNumber,
      'uid': _auth.currentUser!.uid,
      'days': days,
      'description': description,
      'email': email,
      'hours': hours,
      'location': location,
      'profileImage': profileImage,
      'storeName': storeName,
      'workType': workType,
      'isCommercial': true,
      'provider': 'email',
      'followers': [],
      'following': [],
      'hasMessages': false,
    });
    return true;
  }

  Future<Users> getUser({String? UID}) async {
    try {
      final user = await _firebaseFirestore
          .collection('users')
          .doc(UID ?? _auth.currentUser!.uid)
          .get();
      return Users.fromSnap(user);
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<void> saveGoogleUser(User user) async {
    await _firebaseFirestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'isCommercial': false,
      'provider': 'google',
      'followers': [],
      'following': [],
      'hasMessages': false,
    }, SetOptions(merge: true));
  }

  // دوال المنشورات
  Stream<List<Post>> getPosts() {
    return _firebaseFirestore
        .collection('posts')
        .orderBy('datePublished', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromSnap(doc)).toList();
    });
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _firebaseFirestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('datePublished', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromSnap(doc)).toList();
    });
  }

  Future<void> likePost(String postId, String userId) async {
    await _firebaseFirestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _firebaseFirestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayRemove([userId])
    });
  }

  Future<void> sendChatMessage({
    required String receiverId,
    String? text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // إضافة الرسالة لكلا الطرفين
    final messageId = _uuid.v1();
    
    await _firebaseFirestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);

    await _firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(currentUserId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);

    // تحديث حالة الرسائل
    await _updateUserMessagesStatus(currentUserId);
    await _updateUserMessagesStatus(receiverId);

    // تحديث آخر رسالة
    await _updateLastMessage(currentUserId, receiverId, text, imageUrl, audioUrl);
  }

  Future<void> sendOrderConfirmation({
    required String receiverId,
    required String orderId,
    required String productDescription,
    String? productImage,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final messageId = _uuid.v1();
    final timestamp = FieldValue.serverTimestamp();
    final messageText = 'تم إنشاء طلب جديد للمنتج: $productDescription';

    // بيانات الرسالة الأساسية
    final messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': messageText,
      'timestamp': timestamp,
      'isRead': false,
      'isOrderMessage': true,
      'orderId': orderId,
    };

    // إرسال الرسالة لكلا الطرفين
    await _firebaseFirestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);

    await _firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(currentUserId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);

    // إرسال صورة المنتج إذا كانت موجودة
    if (productImage != null) {
      final imageMessageId = _uuid.v1();
      final imageMessageData = {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'imageUrl': productImage,
        'timestamp': timestamp,
        'isRead': false,
      };

      await _firebaseFirestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .doc(imageMessageId)
          .set(imageMessageData);

      await _firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(currentUserId)
          .collection('messages')
          .doc(imageMessageId)
          .set(imageMessageData);
    }

    // تحديث سجل المحادثة لكلا الطرفين
    await _updateLastMessage(currentUserId, receiverId, messageText, null, null);
    await _updateLastMessage(receiverId, currentUserId, messageText, null, null);

    // تحديث حالة وجود رسائل لكلا المستخدمين
    await _updateUserMessagesStatus(currentUserId);
    await _updateUserMessagesStatus(receiverId);
  }

  Future<void> _updateLastMessage(
    String currentUserId,
    String receiverId,
    String? text,
    String? imageUrl,
    String? audioUrl,
  ) async {
    final lastMessage = text ?? (imageUrl != null ? 'صورة' : 'رسالة صوتية');

    await _firebaseFirestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(receiverId)
        .set({
      'lastMessage': lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> _updateUserMessagesStatus(String userId) async {
    await _firebaseFirestore.collection('users').doc(userId).update({
      'hasMessages': true,
    });
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
    return _firebaseFirestore
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
    final batch = _firebaseFirestore.batch();

    for (final messageId in messageIds) {
      final messageRef = _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(otherUserId)
          .collection('messages')
          .doc(messageId);

      batch.update(messageRef, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteMessages(
      String userId, String otherUserId, bool deleteForBoth) async {
    // حذف من المستخدم الحالي
    final currentUserMessages = await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(otherUserId)
        .collection('messages')
        .get();

    final batch1 = _firebaseFirestore.batch();
    for (var doc in currentUserMessages.docs) {
      batch1.delete(doc.reference);
    }
    await batch1.commit();

    // إذا طلب حذف من الطرفين
    if (deleteForBoth) {
      final otherUserMessages = await _firebaseFirestore
          .collection('users')
          .doc(otherUserId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .get();

      final batch2 = _firebaseFirestore.batch();
      for (var doc in otherUserMessages.docs) {
        batch2.delete(doc.reference);
      }
      await batch2.commit();
    }

    // تحديث حالة وجود رسائل
    await _updateHasMessagesStatus(userId);
    if (deleteForBoth) {
      await _updateHasMessagesStatus(otherUserId);
    }
  }

  Future<void> _updateHasMessagesStatus(String userId) async {
    final messages = await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .get();

    final hasMessages = messages.docs.isNotEmpty;
    await _firebaseFirestore.collection('users').doc(userId).update({
      'hasMessages': hasMessages,
    });
  }
}