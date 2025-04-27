import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/profile/videoDetails.dart';
import 'package:video_player/video_player.dart';

class UserVideosView extends StatelessWidget {
  final String userId;

  const UserVideosView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: userId)
            .where('isVideo', isEqualTo: true)
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لم يتم نشر أي فيديوهات بعد"));
          }

          final allVideos = snapshot.data!.docs;

          // ✅ فلترة الفيديوهات غير المحذوفة فقط
          final videos = allVideos.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isDeleted'] != true;
          }).toList();

          if (videos.isEmpty) {
            return const Center(child: Text("لم يتم نشر أي فيديوهات بعد"));
          }

          return GridView.builder(
            itemCount: videos.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 9 / 16,
            ),
            itemBuilder: (context, index) {
              final videoDoc = videos[index];
              final videoData = videoDoc.data() as Map<String, dynamic>;
              final videoUrl = videoData['videoUrl'];
              final postId = videoDoc.id;

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: VideoThumbnailWidget(
                  videoUrl: videoUrl,
                  postId: postId,
                  userId: userId,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final String postId;
  final String userId;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    required this.postId,
    required this.userId,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.setVolume(0);
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserVideoPostsViewScreen(
              userId: widget.userId,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
          const Icon(Icons.play_circle_fill, size: 50, color: Colors.white70),
        ],
      ),
    );
  }
}
