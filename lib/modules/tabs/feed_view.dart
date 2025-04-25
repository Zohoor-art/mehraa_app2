import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mehra_app/modules/profile/postDetails_screen.dart';
import 'package:video_player/video_player.dart';

class FeedView extends StatelessWidget {
  final String userId;

  const FeedView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: userId)
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد منشورات"));
          }

          // ✅ فلترة المنشورات غير المحذوفة فقط
          final allPosts = snapshot.data!.docs;
          final posts = allPosts.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isDeleted'] != true;
          }).toList();

          if (posts.isEmpty) {
            return const Center(child: Text("لا توجد منشورات"));
          }

          return MasonryGridView.builder(
            itemCount: posts.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final isImage = data.containsKey('postUrl');
              final mediaUrl = isImage ? data['postUrl'] : data['videoUrl'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserPostsViewScreen(userId: userId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: isImage
                        ? Image.network(
                            mediaUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 150,
                              color: Colors.grey,
                              child: const Center(child: Icon(Icons.error)),
                            ),
                          )
                        : _VideoThumbnail(videoUrl: mediaUrl),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final String videoUrl;

  const _VideoThumbnail({super.key, required this.videoUrl});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              const Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
            ],
          )
        : Container(
            height: 150,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
  }
}
