import 'package:flutter/material.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:story_view/story_view.dart';
import 'package:mehra_app/models/story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryViewPage extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewPage({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _StoryViewPageState createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  final StoryController _storyController = StoryController();
  Users? user;
  late List<StoryItem> storyItems;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _prepareStoryItems();
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final currentStory = widget.stories[widget.initialIndex];
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentStory.userId)
        .get();
    if (userDoc.exists) {
      setState(() {
        user = Users.fromSnap(userDoc);
      });
    }
  }

  void _prepareStoryItems() {
    storyItems = widget.stories.map((story) {
      if (story.mediaType == 'image') {
        return StoryItem.pageImage(
          url: story.mediaUrl,
          caption: story.caption != null && story.caption!.isNotEmpty
              ? Text(
                  story.caption!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                )
              : null,
          controller: _storyController,
        );
      } else {
        return StoryItem.text(
          title: story.caption ?? '',
          backgroundColor: Colors.deepPurple,
          textStyle: const TextStyle(fontSize: 20),
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            StoryView(
              storyItems: storyItems,
              controller: _storyController,
              onStoryShow: (storyItem, index) {
                final currentStory = widget.stories[index];
                final caption = currentStory.caption?.isNotEmpty == true
                    ? currentStory.caption
                    : 'بدون تعليق';
                print('✅ عرض الستوري رقم ${index + 1}: $caption');
              },
              onComplete: () {
                Navigator.pop(context);
              },
              repeat: false,
            ),
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user?.profileImage ??
                          'https://via.placeholder.com/150',
                    ),
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user?.storeName ?? 'مستخدم',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
