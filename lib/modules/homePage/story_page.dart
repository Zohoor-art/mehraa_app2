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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class StoryPage extends StatelessWidget {
  const StoryPage({Key? key}) : super(key: key);

  Future<Users?> _getUser(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return Users.fromSnap(userDoc);
    }
    return null;
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

        final myStories = docs.where((doc) {
          try {
            return doc['userId'] == currentUserId;
          } catch (e) {
            return false;
          }
        }).toList();

        final otherStories = docs.where((doc) {
          try {
            return doc['userId'] != currentUserId;
          } catch (e) {
            return false;
          }
        }).toList();

        final Map<String, List<Story>> userStoriesMap = {};

        for (var doc in otherStories) {
          final story = Story.fromDocumentSnapshot(doc);
          if (!userStoriesMap.containsKey(story.userId)) {
            userStoriesMap[story.userId] = [];
          }
          userStoriesMap[story.userId]!.add(story);
        }

        return SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildMyStoryButton(context, myStories),
              if (userStoriesMap.isNotEmpty)
                ...userStoriesMap.entries.map((entry) {
                  final userId = entry.key;
                  final userStories = entry.value;

                  if (userStories.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return FutureBuilder<Users?>(
                    future: _getUser(userId),
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data;

                      return Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserStoriesPage(userId: userId),
                              ),
                            );
                          },
                          child: _buildStoryItem(context, userStories.first, user),
                        ),
                      );
                    },
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyStoryButton(BuildContext context, List myStories) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<Users?>(
      future: _getUser(currentUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Padding(
          padding: const EdgeInsets.all(7.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserStoriesPage(userId: currentUserId),
                ),
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
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff9022B2), Color(0xffEEAB63)],
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
                        child: user != null && user.profileImage != null
                            ? Image.network(
                                user.profileImage!,
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
                const Text('قصتي', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoryItem(BuildContext context, Story story, Users? user) {
    return Column(
      children: [
        ClipPath(
          clipper: HouseClipper(),
          child: Container(
            width: 70,
            height: 77,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff9022B2), Color(0xffEEAB63)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ClipPath(
              clipper: HouseClipper(),
              child: Container(
                width: 60,
                height: 67,
                color: Colors.white,
                child: user != null && user.profileImage != null
                    ? Image.network(
                        user.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 30),
                      )
                    : const Icon(Icons.person, size: 30),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Column(
            children: [
              Text(
                story.caption ?? '',
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                user?.storeName ?? 'مستخدم',
                style: const TextStyle(fontSize: 9, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
