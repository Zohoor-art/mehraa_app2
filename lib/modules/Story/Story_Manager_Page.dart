import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoryManagerPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StoryManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠 إدارة قصصي'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('stories')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('🚫 لا توجد قصص لإدارتها.'));
          }

          final stories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(story['mediaUrl']),
                  radius: 25,
                ),
                title: Text(story['caption'] ?? 'بدون عنوان'),
                subtitle: Text('تاريخ النشر: ${story['timestamp'].toDate().toLocal()}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () async {
                    await _firestore.collection('stories').doc(story.id).delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🗑️ تم حذف القصة بنجاح')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
