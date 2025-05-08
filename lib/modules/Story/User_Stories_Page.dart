import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/story.dart';
import 'package:mehra_app/modules/Story/Story_View_Page.dart';

class UserStoriesPage extends StatefulWidget {
  final String userId;

  const UserStoriesPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserStoriesPage> createState() => _UserStoriesPageState();
}

class _UserStoriesPageState extends State<UserStoriesPage> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('حالات المستخدم')),
            body: const Center(child: Text('🚫 لا توجد قصص متاحة لهذا المستخدم.')),
          );
        }

        final stories = snapshot.data!.docs
            .map((doc) => Story.fromDocumentSnapshot(doc))
            .toList();

        final groupedStories = [stories];

        // ✅ نمنع التنقل أكثر من مرة
        if (!_navigated && mounted) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StoryViewPage(
                  groupedStories: groupedStories,
                  initialGroupIndex: 0,
                  initialStoryIndex: 0,
                ),
              ),
            );
          });
        }

        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
