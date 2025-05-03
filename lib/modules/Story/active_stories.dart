import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/story.dart';
import 'story_view_page.dart'; // تأكد تستورد StoryViewPage الصح

class ActiveStoriesPage extends StatefulWidget {
  const ActiveStoriesPage({Key? key}) : super(key: key);

  @override
  _ActiveStoriesPageState createState() => _ActiveStoriesPageState();
}

class _ActiveStoriesPageState extends State<ActiveStoriesPage> {
  List<Story> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveStories();
  }

  Future<void> _fetchActiveStories() async {
    final now = Timestamp.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('stories')
        .where('timestamp', isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch - (24 * 60 * 60 * 1000),
        )) // جلب الاستوريات الأحدث من 24 ساعة مضت
        .orderBy('timestamp', descending: true)
        .get();

    List<Story> tempStories = [];

    for (var doc in snapshot.docs) {
      final story = Story.fromDocumentSnapshot(doc);

      // تحقق إضافي لو انتهى الوقت نحذفه
      final storyTime = story.timestamp.toDate();
      if (DateTime.now().difference(storyTime).inHours >= 24) {
        // حذف من فايرستور
        await FirebaseFirestore.instance.collection('stories').doc(doc.id).delete();
        print('🗑️ حذفنا ستوري قديم تلقائيًا.');
      } else {
        tempStories.add(story);
      }
    }

    setState(() {
      _stories = tempStories;
      _isLoading = false;
    });
  }

  void _openStoryView(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewPage(
          stories: _stories,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاستوريات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? const Center(child: Text('لا توجد استوريات حاليًا 💤'))
              : ListView.builder(
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(story.mediaUrl),
                      ),
                      title: Text(story.caption ?? 'بدون تعليق'),
                      subtitle: Text(
                        story.timestamp.toDate().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => _openStoryView(index),
                    );
                  },
                ),
    );
  }
}
