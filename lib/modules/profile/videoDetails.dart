import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/homePage/post.dart';

class UserVideoPostsViewScreen extends StatefulWidget {
  final String userId;

  const UserVideoPostsViewScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserVideoPostsViewScreen> createState() => _UserVideoPostsViewScreenState();
}

class _UserVideoPostsViewScreenState extends State<UserVideoPostsViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('فيديوهات المستخدم', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.userId)
            .where('isVideo', isEqualTo: true) // فقط فيديوهات
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final videoPosts = snapshot.data!.docs;

          if (videoPosts.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد فيديوهات لهذا المستخدم',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: videoPosts.length,
            itemBuilder: (context, index) {
              return PostWidget(
                post: Post.fromSnap(videoPosts[index]),
                currentUserId: widget.userId,
              );
            },
          );
        },
      ),
    );
  }
}
