import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:share_plus/share_plus.dart';

class PostActions {
  static Future<void> copyLink(BuildContext context, String postId) async {
    final String postUrl = "https://mehra.app/post/$postId";
    await Clipboard.setData(ClipboardData(text: postUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ الرابط')),
    );
  }

  static void sharePost(String postId, int currentShareCount) async {
    final String postUrl = "https://mehra.app/post/$postId";
    Share.share('شوف هذا المنشور: $postUrl');

    // تحديث عدد المشاركات في Firestore
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'shareCount': currentShareCount + 1,
    });
  }

  static Future<void> reportPost(BuildContext context, String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('reports').add({
      'postId': postId,
      'reportedAt': Timestamp.now(),
      'reportedBy': currentUser?.uid,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال البلاغ')),
    );
  }

  static Future<void> unfollowUser(BuildContext context, String userId) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser!.uid)
      .collection('following')
      .doc(userId)
      .delete();

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('followers')
      .doc(currentUser.uid)
      .delete();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('تم إلغاء المتابعة')),
  );
}

static Future<void> hidePost(BuildContext context, String postId) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('يجب تسجيل الدخول لإخفاء المنشور')),
    );
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('hiddenPosts')
        .doc(postId)
        .set({'hiddenAt': Timestamp.now()});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إخفاء المنشور')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء إخفاء المنشور')),
    );
    debugPrint('Error in hidePost: $e');
  }
}


 static void goToUserProfile(BuildContext context, String userId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(userId: userId),
    ),
  );
}

}
