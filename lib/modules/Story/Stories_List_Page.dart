import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/story.dart';

import 'package:mehra_app/modules/Story/Story_View_Page.dart';

class StoriesListPage extends StatelessWidget {
  const StoriesListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كل القصص 📖'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stories')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد قصص حالياً'));
          }

          final stories = snapshot.data!.docs
              .map((doc) => Story.fromDocumentSnapshot(doc))
              .toList();

          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(story.mediaUrl),
                  radius: 30,
                ),
                title: Text(story.caption ?? 'بدون عنوان'),
                subtitle: Text('${story.timestamp.toDate().hour}:${story.timestamp.toDate().minute}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryViewPage(
                        stories: [story],
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
