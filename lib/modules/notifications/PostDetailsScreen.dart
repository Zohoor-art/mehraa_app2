import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/homePage/post.dart';
import 'package:mehra_app/shared/components/constants.dart';

class PostDetailsScreen extends StatelessWidget {
  final String postId;

  const PostDetailsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text('تفاصيل المنشور', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text(
              'المنشور غير موجود',
              style: TextStyle(color: Colors.white),
            ));
          }

          final post = Post.fromSnap(snapshot.data!);

          return PostWidget(
            post: post,
            currentUserId: post.uid, // استخدم معرف صاحب المنشور
          );
        },
      ),
    );
  }
}
