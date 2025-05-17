import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:story_view/story_view.dart';
import 'package:mehra_app/models/story.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/modules/Story/story_views.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mehra_app/modules/chats/chat_room.dart';

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
  Map<String, int> likesCount = {};
  Map<String, int> viewsCount = {};

  String? currentUserId;
  int currentGroupIndex = 0;
  int currentStoryIndex = 0;
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
          title: story.caption ?? 'يومية',
          backgroundColor:
              Color(story.backgroundColor ?? Colors.deepPurple.value),
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
        final storyDoc = FirebaseFirestore.instance
            .collection('stories')
            .doc(shownStory.storyId);

        final docSnapshot = await storyDoc.get();
        if (!docSnapshot.exists) return;

        final viewsData = docSnapshot.data()?['views'] ?? {};
        final views = Map<String, dynamic>.from(viewsData);

        if (!views.containsKey(currentUserId)) {
          await storyDoc.update({
            'views.${currentUserId!}': FieldValue.serverTimestamp(),
          });
          print('✅ سجلنا مشاهدة للستوري: ${shownStory.storyId}');
        }

        final likesData = docSnapshot.data()?['likes'] ?? {};
        final likes = Map<String, dynamic>.from(likesData);

        setState(() {
          likedStories[shownStory.storyId] = likes.containsKey(currentUserId);
          viewsCount[shownStory.storyId] = views.length;
          likesCount[shownStory.storyId] = likes.length;
        });
      }
    } catch (e) {
      print('❌ خطأ أثناء تسجيل المشاهدة: $e');
    }
  }

  Future<void> _toggleLike(Story story) async {
    final storyDoc =
        FirebaseFirestore.instance.collection('stories').doc(story.storyId);
    final docSnapshot = await storyDoc.get();

    try {
      final likesData = docSnapshot.data()?['likes'] ?? {};
      final likes = Map<String, dynamic>.from(likesData);

      final isLiked = likes.containsKey(currentUserId);

      if (isLiked) {
        await storyDoc.update({
          'likes.${currentUserId!}': FieldValue.delete(),
        });
        setState(() {
          likedStories[story.storyId] = false;
          likesCount[story.storyId] = likesCount[story.storyId]! - 1;
        });
      } else {
        await storyDoc.update({
          'likes.${currentUserId!}': true,
        });
        setState(() {
          likedStories[story.storyId] = true;
          likesCount[story.storyId] = (likesCount[story.storyId] ?? 0) + 1;
        });
      }
    } catch (e) {
      print("❌ خطأ أثناء تسجيل اللايك: $e");
    }
  }

  Future<void> _sendReply(Story story) async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoom(
            userId: story.userId,
            userName: user?.storeName ?? 'مستخدم',
            repliedStory: story, // إرسال الستوري كمعامل
          ),
        ),
      );
      
      _messageController.clear();
      FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم فتح المحادثة لإرسال الرد'),
            duration: Duration(seconds: 2)
          ),
        );
      }
    } catch (e) {
      print('❌ خطأ أثناء فتح المحادثة: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ حدث خطأ أثناء فتح المحادثة'),
            duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final currentStory =
        originalStories.isNotEmpty && currentStoryIndex < originalStories.length
            ? originalStories[currentStoryIndex]
            : null;

    if (isLoading || storyItems.isEmpty || currentStory == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final isStoryOwner = currentStory.userId == currentUserId;
    final likes = likesCount[currentStory.storyId] ?? 0;
    final views = viewsCount[currentStory.storyId] ?? 0;

    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
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
              onComplete: _goToNextUser,
              repeat: false,
              inline: false,
              progressPosition: ProgressPosition.top,
              indicatorForegroundColor: Colors.white,
            ),
            Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user?.profileImage ?? 'https://via.placeholder.com/150',
                    ),
                    radius: isSmallScreen ? 18 : 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.storeName ?? 'مستخدم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeago.format(currentStory.timestamp, locale: 'ar'),
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSmallScreen ? 10 : 12),
                        ),
                      ],
                    ),
                  ),
                  if (isStoryOwner) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StoryViewersPage(storyId: currentStory.storyId),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.remove_red_eye,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              views.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
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
                      height: isSmallScreen ? 40 : 48,
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "أرسل رسالة...",
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _sendReply(currentStory),
                            child: const Icon(Icons.send,
                                color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _toggleLike(currentStory),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (likedStories[currentStory.storyId] ?? false)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: (likedStories[currentStory.storyId] ?? false)
                                ? Colors.red
                                : Colors.white,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          if (isStoryOwner) ...[
                            const SizedBox(width: 4),
                            Text(
                              likes.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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