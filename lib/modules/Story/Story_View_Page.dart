import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:story_view/story_view.dart';
import 'package:mehra_app/models/story.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/modules/Story/story_views.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryViewPage extends StatefulWidget {
  final List<List<Story>> groupedStories;
  final int initialGroupIndex;
  final int initialStoryIndex;

  const StoryViewPage({
    Key? key,
    required this.groupedStories,
    this.initialGroupIndex = 0,
    this.initialStoryIndex = 0,
  }) : super(key: key);

  @override
  _StoryViewPageState createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  final StoryController _storyController = StoryController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Users? user;
  List<StoryItem> storyItems = [];
  List<Story> originalStories = [];
  Map<String, bool> likedStories = {};

  String? currentUserId;
  int currentGroupIndex = 0;
  int currentStoryIndex = 0;
  bool showSendButton = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentGroupIndex = widget.initialGroupIndex;
    currentStoryIndex = widget.initialStoryIndex;
    currentUserId = FirebaseAuth.instance.currentUser?.uid;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _storyController.pause();
      } else {
        _storyController.play();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeStories());
  }

  @override
  void dispose() {
    _storyController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeStories() async {
    if (!mounted) return;
    await _loadUserInfo();
    _prepareStoryItems();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final currentStories = widget.groupedStories[currentGroupIndex];
      if (currentStories.isEmpty) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentStories.first.userId)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          user = Users.fromSnap(userDoc);
        });
      }
    } catch (e) {
      print('❌ Error loading user info: $e');
    }
  }

  void _prepareStoryItems() {
    final currentStories = widget.groupedStories[currentGroupIndex];
    if (currentStories.isEmpty) return;

    originalStories = currentStories;
    storyItems = currentStories.map((story) {
      if (story.mediaType == 'image') {
        return StoryItem.pageImage(
          url: story.mediaUrl,
          controller: _storyController,
          caption: story.caption != null && story.caption!.isNotEmpty
              ? Text(
                  story.caption!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                )
              : null,
          duration: const Duration(seconds: 10),
        );
      } else if (story.mediaType == 'video') {
        return StoryItem.pageVideo(
          story.mediaUrl,
          controller: _storyController,
          caption: story.caption != null && story.caption!.isNotEmpty
              ? Text(
                  story.caption!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                )
              : null,
          duration: const Duration(seconds: 30),
        );
      } else {
        return StoryItem.text(
          title: story.caption ?? 'ستوري',
          backgroundColor: Colors.deepPurple,
          textStyle: const TextStyle(fontSize: 20),
          duration: const Duration(seconds: 10),
        );
      }
    }).toList();
  }

  void _goToNextUser() {
    if (currentGroupIndex < widget.groupedStories.length - 1) {
      setState(() {
        currentGroupIndex++;
        isLoading = true;
      });
      _initializeStories();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleStoryView(int storyIndex) async {
    try {
      if (storyIndex < originalStories.length) {
        final shownStory = originalStories[storyIndex];
        final storyDoc = FirebaseFirestore.instance.collection('stories').doc(shownStory.storyId);

        final docSnapshot = await storyDoc.get();
        if (!docSnapshot.exists) return;

        final views = (docSnapshot.data()?['views'] ?? {}) as Map<String, dynamic>;

        if (!(views.keys.contains(currentUserId))) {
          await storyDoc.update({
            'views.${currentUserId!}': FieldValue.serverTimestamp(),
          });
          print('✅ سجلنا مشاهدة للستوري: ${shownStory.storyId}');
        }

        final likes = (docSnapshot.data()?['likes'] ?? {}) as Map<String, dynamic>;
        setState(() {
          likedStories[shownStory.storyId] = likes.keys.contains(currentUserId);
        });
      }
    } catch (e) {
      print('❌ خطأ أثناء تسجيل المشاهدة: $e');
    }
  }

  Future<void> _toggleLike(Story story) async {
    final storyDoc = FirebaseFirestore.instance.collection('stories').doc(story.storyId);
    final docSnapshot = await storyDoc.get();

    try {
      final rawLikes = docSnapshot.data()?['likes'] ?? {};
      final likes = Map<String, dynamic>.from(rawLikes);
      final isLiked = likes.containsKey(currentUserId);

      if (isLiked) {
        await storyDoc.update({
          'likes.${currentUserId!}': FieldValue.delete(),
        });
        setState(() {
          likedStories[story.storyId] = false;
        });
      } else {
        await storyDoc.update({
          'likes.${currentUserId!}': true,
        });
        setState(() {
          likedStories[story.storyId] = true;
        });
      }
    } catch (e) {
      print("❌ خطأ أثناء تسجيل اللايك: $e");
    }
  }

  Future<void> _sendReply(Story story) async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    await FirebaseFirestore.instance.collection('chats').add({
      'receiverId': story.userId,
      'senderId': currentUserId,
      'message': messageText,
      'storyThumbnail': story.mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
    if (mounted) {
      setState(() {
        showSendButton = false;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم إرسال الرد')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || storyItems.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final currentStory = originalStories[currentStoryIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            StoryView(
              storyItems: storyItems,
              controller: _storyController,
              onStoryShow: (storyItem, storyIndex) {
                _handleStoryView(storyIndex);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      currentStoryIndex = storyIndex;
                    });
                  }
                });
              },
              onComplete: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _goToNextUser();
                });
              },
              repeat: false,
              inline: false,
              progressPosition: ProgressPosition.top,
              indicatorForegroundColor: Color(0xFFB388FF),
            ),
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user?.profileImage ?? 'https://via.placeholder.com/150',
                    ),
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.storeName ?? 'مستخدم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeago.format(currentStory.timestamp, locale: 'ar'),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoryViewersPage(storyId: currentStory.storyId),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (text) {
                          setState(() {
                            showSendButton = text.trim().isNotEmpty;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "أرسل رسالة...",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _toggleLike(currentStory),
                    child: Icon(
                      (likedStories[currentStory.storyId] ?? false)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: (likedStories[currentStory.storyId] ?? false)
                          ? Colors.purple
                          : Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (showSendButton)
                    GestureDetector(
                      onTap: () => _sendReply(currentStory),
                      child: const Icon(Icons.send, color: Colors.white, size: 28),
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
