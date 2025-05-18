import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/models/story.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/modules/Story/Create_Story_Page.dart';
import 'package:mehra_app/modules/Story/User_Stories_Page.dart';
import 'package:mehra_app/modules/register/register_screen.dart';

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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'يرجى تسجيل الدخول أولًا لإنشاء ومشاهدة اليوميات',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()), // عدل حسب اسم شاشتك
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(left: 5, right: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff9022B2), Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  alignment: Alignment.center,
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final String currentUserId = currentUser.uid;

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
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String? currentUserId = currentUser?.uid;

  if (currentUserId == null) {
    return const SizedBox.shrink();
  }

  bool hasStories = myStories.isNotEmpty;
  bool allOpened = myStories.every((story) => story.isOpened);

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
                  if (hasStories)
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
                  // زر الإضافة مع شرط الحساب التجاري
                  Positioned(
                    bottom: -2,
                    right: -1,
                    child: GestureDetector(
                      onTap: () {
                        if (user?.isCommercial == false) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('تنبيه'),
                                content: const Text('يجب أن تكون مسجلًا بحساب تجاري لإنشاء ستوري.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('حسناً'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CreateStoryPage()),
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
              const SizedBox(
                width: 70,
                child: Text(
                  'يومياتي',
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
                  // تم حذف Positioned الذي يحتوي زر الإضافة هنا
                ],
              ),
              const SizedBox(height: 6),
              Text(
                user?.storeName ?? 'مستخدم',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  );
}

}
