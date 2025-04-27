import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/homePage/post.dart';

class UserPostsViewScreen extends StatefulWidget {
  final String userId;

  const UserPostsViewScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserPostsViewScreen> createState() => _UserPostsViewScreenState();
}

class _UserPostsViewScreenState extends State<UserPostsViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // زي تصميم ميهرا
      appBar: AppBar(
        title: const Text('منشورات المستخدم', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.userId)
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد منشورات لهذا المستخدم',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostWidget(
                post: Post.fromSnap(posts[index]),
                currentUserId: widget.userId, // صح هنا!
              );
            },
          );
        },
      ),
    );
  }
}
