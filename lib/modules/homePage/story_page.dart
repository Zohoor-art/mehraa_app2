import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/models/story.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/modules/Story/Create_Story_Page.dart';
import 'package:mehra_app/modules/Story/User_Stories_Page.dart';

class HouseClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.25);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class StoryPage extends StatelessWidget {
  const StoryPage({Key? key}) : super(key: key);

  Future<Users?> _getUser(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return Users.fromSnap(doc);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _markStoriesAsOpened(List<Story> stories) async {
    for (var story in stories) {
      if (!story.isOpened) {
        await FirebaseFirestore.instance.collection('stories').doc(story.storyId).update({
          'isOpened': true,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        final myStories = docs
            .where((doc) => doc['userId'] == currentUserId)
            .map((doc) => Story.fromDocumentSnapshot(doc))
            .toList();

        final otherStories = docs
            .where((doc) => doc['userId'] != currentUserId)
            .map((doc) => Story.fromDocumentSnapshot(doc))
            .toList();


        final Map<String, List<Story>> groupedStories = {};


        for (var story in otherStories) {
          groupedStories.putIfAbsent(story.userId, () => []).add(story);
        }

        final activeStories = groupedStories.entries.where(
          (entry) => entry.value.any((story) => !story.isOpened),
        );
        final openedStories = groupedStories.entries.where(
          (entry) => entry.value.every((story) => story.isOpened),
        );

        final sortedStories = [...activeStories, ...openedStories];

        return SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildMyStoryButton(context, myStories),
              ...sortedStories.map((entry) => _buildStoryItem(context, entry.key, entry.value)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyStoryButton(BuildContext context, List<Story> myStories) {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  bool hasStories = myStories.isNotEmpty;
  bool allOpened = myStories.every((story) => story.isOpened);
  bool anyUnopened = myStories.any((story) => !story.isOpened);

  return FutureBuilder<Users?>(
    future: _getUser(currentUserId),
    builder: (context, snapshot) {
      final user = snapshot.data;

      return Padding(
        padding: const EdgeInsets.all(7.0),
        child: InkWell(
          onTap: hasStories
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserStoriesPage(userId: currentUserId)),
                  );
                }
              : null,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (hasStories) // 🟢 إظهار الإطار فقط إذا فيه ستوري
                    ClipPath(
                      clipper: HouseClipper(),
                      child: Container(
                        width: 70,
                        height: 77,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: allOpened
                                ? [Colors.grey, Colors.grey]
                                : [Color(0xff9022B2), Color(0xffEEAB63)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ClipPath(
                    clipper: HouseClipper(),
                    child: Container(
                      width: 60,
                      height: 67,
                      color: Colors.white,
                      child: user?.profileImage != null
                          ? Image.network(
                              user!.profileImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.person, size: 40),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreateStoryPage()),
                        );
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.pink, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const SizedBox(
                width: 70,
                child: Text(
                  'قصتي',
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildStoryItem(BuildContext context, String userId, List<Story> stories) {
    bool allOpened = stories.every((story) => story.isOpened);

    return FutureBuilder<Users?>(
      future: _getUser(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Padding(
          padding: const EdgeInsets.all(7.0),
          child: InkWell(
            onTap: () async {
              await _markStoriesAsOpened(stories);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserStoriesPage(userId: userId)),
              );
            },
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipPath(
                      clipper: HouseClipper(),
                      child: Container(
                        width: 70,
                        height: 77,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: allOpened
                                ? [Colors.grey, Colors.grey]
                                : [Color(0xff9022B2), Color(0xffEEAB63)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    ClipPath(
                      clipper: HouseClipper(),
                      child: Container(
                        width: 60,
                        height: 67,
                        color: Colors.white,
                        child: user?.profileImage != null
                            ? Image.network(
                                user!.profileImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                              )
                            : const Icon(Icons.person, size: 40),
                      ),
                    ),

                    Positioned(
                      bottom: -2,
                      right: -1,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CreateStoryPage()),
                          );

                          if (result == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ تم نشر الستوري بنجاح!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.pink, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 70,
                  child: Text(
                    user?.storeName ?? 'مستخدم',
                    style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 23, 8, 8) ,fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
