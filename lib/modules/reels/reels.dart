import 'package:flutter/material.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/reels/options_screen.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ContentScreen extends StatefulWidget {
  final Post post;

  const ContentScreen({Key? key, required this.post}) : super(key: key);

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _liked = false;
  bool _showControls = false;
  bool _isPlaying = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
    _liked = widget.post.likes.contains('currentUserId');
  }

  Future<void> initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.post.videoUrl);
      await _videoPlayerController.initialize();
      
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          showControls: false,
          looping: true,
          allowFullScreen: false,
          allowMuting: false,
          showOptions: false,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          placeholder: Container(color: Colors.black),
        );
        _isInitialized = true;
      });

      _videoPlayerController.addListener(_videoListener);
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  void _videoListener() {
    if (_videoPlayerController.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = _videoPlayerController.value.isPlaying;
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying ? _videoPlayerController.pause() : _videoPlayerController.play();
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // الفيديو الخلفي
          if (_isInitialized && _chewieController != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControls,
              onDoubleTap: () {
                setState(() => _liked = !_liked);
                // تحديث حالة الإعجاب في Firebase هنا
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('جاري التحميل...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

          // عناصر التحكم (زر التشغيل/الإيقاف فقط)
          if (_showControls && _isInitialized)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleControls,
                child: Container(
                  color: Colors.black38,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ),
              ),
            ),

          // شريط التقدم
          if (_isInitialized)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: VideoProgressIndicator(
                  _videoPlayerController,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: MyColor.blueColor,
                    bufferedColor: Colors.grey[600]!,
                    backgroundColor: Colors.grey[800]!,
                  ),
                ),
              ),
            ),

          // خيارات الفيديو الجانبية
          if (_isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: OptionsScreen(
                post: widget.post,
                currentUserId: '', // استبدل بآيدي المستخدم الحقيقي
              ),
            ),
        ],
      ),
    );
  }
}