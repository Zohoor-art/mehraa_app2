import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/userModel.dart';

class StoryViewersPage extends StatelessWidget {
  final String storyId;

  const StoryViewersPage({Key? key, required this.storyId}) : super(key: key);

  Future<List<Users>> _fetchViewers() async {
    final viewersSnapshot = await FirebaseFirestore.instance
        .collection('storyViews')
        .where('storyId', isEqualTo: storyId)
        .get();

    final viewerIds = viewersSnapshot.docs.map((doc) => doc['viewerId'] as String).toList();

    final users = <Users>[];

    for (var id in viewerIds) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (userDoc.exists) {
        users.add(Users.fromSnap(userDoc));
      }
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👁️ المشاهدات'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Users>>(
        future: _fetchViewers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('🚫 لا مشاهدات حتى الآن.', style: TextStyle(color: Colors.white)));
          }

          final viewers = snapshot.data!;

          return ListView.builder(
            itemCount: viewers.length,
            itemBuilder: (context, index) {
              final user = viewers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profileImage ?? 'https://via.placeholder.com/150'),
                ),
                title: Text(
                  user.storeName ?? 'مستخدم',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
