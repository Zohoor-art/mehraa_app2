import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/story.dart';

import 'package:mehra_app/modules/Story/Story_View_Page.dart';

class UserStoriesPage extends StatelessWidget {
  final String userId;

  const UserStoriesPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: false) // ترتبهم حسب الأقدم للأحدث
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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

        // نفتح الستوريهات باستخدام StoryViewPage مباشرة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StoryViewPage(
                stories: stories,
                initialIndex: 0,
              ),
            ),
          );
        });

        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()), // وقت ما يجهز التبديل
        );
      },
    );
  }
}
