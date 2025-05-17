import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/homePage/post.dart';
import 'package:mehra_app/shared/components/constants.dart';

class UserVideoPostsViewScreen extends StatefulWidget {
  final String userId;

  const UserVideoPostsViewScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserVideoPostsViewScreen> createState() => _UserVideoPostsViewScreenState();
}

class _UserVideoPostsViewScreenState extends State<UserVideoPostsViewScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        title: Center(
          child: Text(
            'فيديوهات المستخدم',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045, // حجم خط متجاوب
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: screenHeight * 0.07, // ارتفاع AppBar متجاوب
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.userId)
            .where('isVideo', isEqualTo: true)
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: screenWidth * 0.01, // سماكة مؤشر التحميل متجاوبة
              ),
            );
          }

          final videoPosts = snapshot.data!.docs;

          if (videoPosts.isEmpty) {
            return Center(
              child: Text(
                'لا توجد فيديوهات لهذا المستخدم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04, // حجم خط متجاوب
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.01, // هامش رأسي متجاوب
            ),
            itemCount: videoPosts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.005, // تباعد بين الفيديوهات
                ),
                child: PostWidget(
                  post: Post.fromSnap(videoPosts[index]),
                  currentUserId: widget.userId,
                ),
              );
            },
          );
        },
      ),
    );
  }
}