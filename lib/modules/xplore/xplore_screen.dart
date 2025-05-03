import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/homePage/post.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:video_player/video_player.dart';

class XploreScreen extends StatelessWidget {
  const XploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FF),
      appBar: AppBar(
        toolbarHeight: 3,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: const XploreBody(),
    );
  }
}

class XploreBody extends StatefulWidget {
  const XploreBody({super.key});

  @override
  _XploreBodyState createState() => _XploreBodyState();
}

class _XploreBodyState extends State<XploreBody> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _searchResults = [];
  bool isLoading = false;
  void _searchPosts(String query) async {
  if (query.isEmpty) {
    setState(() {
      _searchResults = [];
      isLoading = false;
    });
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    // البحث في اسم المتجر بدل الوصف واسم المستخدم
    final usersQuery = FirebaseFirestore.instance
        .collection('users')
        .where('storeName', isGreaterThanOrEqualTo: query)
        .where('storeName', isLessThan: query + 'z');

    final usersSnapshot = await usersQuery.get();

    setState(() {
      _searchResults = usersSnapshot.docs;
      isLoading = false;
    });
  } catch (e) {
    debugPrint('Search error: $e');
    setState(() {
      isLoading = false;
    });
  }
}


 Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getAllPosts() async {
    final result = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('datePublished', descending: true)
        .get();
    return result.docs;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                    future: _searchController.text.isEmpty
                        ? _getAllPosts()
                        : Future.value(_searchResults),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final posts = snapshot.data!;
                      if (posts.isEmpty) {
                        return const Center(child: Text('لا يوجد نتائج'));
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2.0,
                          mainAxisSpacing: 2.0,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final postSnap = posts[index];
                          final post = postSnap.data();
                          final mediaUrl = post['postUrl'] ?? post['videoUrl'] ?? '';
                          final isVideo = post['isVideo'] ?? false;

                          return VideoPostItem(
                            postSnap: postSnap,
                            mediaUrl: mediaUrl,
                            isVideo: isVideo,
                            allPosts: posts,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 55,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 0),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(Icons.search, color: MyColor.blueColor),
              onPressed: () {
                _searchPosts(_searchController.text.trim());
              },
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: TextField(
                focusNode: _focusNode,
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'بحث عن وصف أو اسم متجر',
                  border: InputBorder.none,
                ),
                onSubmitted: _searchPosts,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.notifications_outlined,
              size: 22,
              color: MyColor.blueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPostItem extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> postSnap;
  final String mediaUrl;
  final bool isVideo;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> allPosts;

  const VideoPostItem({
    super.key,
    required this.postSnap,
    required this.mediaUrl,
    required this.isVideo,
    required this.allPosts,
  });

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.mediaUrl);
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostGalleryScreen(
              postId: widget.postSnap.id,
              allPosts: widget.allPosts,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.isVideo
            ? _buildVideoThumbnail()
            : _buildImageThumbnail(),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    if (!_isInitialized) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        const Center(
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white70,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail() {
    return widget.mediaUrl.isEmpty
        ? Container(
            color: Colors.grey[200],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 40,
            ),
          )
        : Image.network(
            widget.mediaUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          );
  }
}

class PostGalleryScreen extends StatelessWidget {
  final String postId;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> allPosts;

  const PostGalleryScreen({
    super.key,
    required this.postId,
    required this.allPosts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: allPosts.length,
          itemBuilder: (context, index) {
            final postSnap = allPosts[index];
            final post = Post.fromSnap(postSnap);
            return PostWidget(post: post, currentUserId: post.uid);
          },
        ),
      ),
    );
  }
}