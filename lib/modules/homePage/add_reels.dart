import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/models/firebase/firestore_methods.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/shared/utils/utils.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';

class CreateReelScreen extends StatefulWidget {
  final String videoPath;

  CreateReelScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  VideoPlayerController? _controller;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void uploadReel(String uid, String storename, String profileImage) async {
    if (_controller != null && _controller!.value.duration.inSeconds > 60) {
      showSnackBar('يجب أن تكون مدة الفيديو أقل من دقيقة واحدة', context);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        await File(widget.videoPath).readAsBytes(),
        uid,
        storename,
        profileImage,
        videoPath: widget.videoPath,
        context: context,
      );

      if (res == 'تم نشر الصورة والفيديو بنجاح') {
        showSnackBar('تم النشر', context);
        clearVideo();

        // الانتقال تلقائيًا إلى الصفحة الرئيسية بعد النشر
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        });
      } else {
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void clearVideo() {
    setState(() {
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
      }
    });
  }

  Future<Users?> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return Users(
        uid: user.uid,
        email: user.email ?? '',
        profileImage: user.photoURL,
        contactNumber: '',
        days: '',
        description: '',
        followers: [],
        following: [],
        hours: '',
        location: '',
        storeName: '',
        workType: '',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Users?>(
      future: fetchUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final user = snapshot.data;
        if (user == null) {
          return Center(child: Text("No user found."));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('إنشاء ريل'),
            actions: [
              TextButton(
                onPressed: () => uploadReel(
                  user.uid,
                  user.storeName ?? 'Default Store Name',
                  user.profileImage ?? '',
                ),
                child: Text('نشر'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading) LinearProgressIndicator(),
                const SizedBox(height: 10),
                if (_controller != null && _controller!.value.isInitialized)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 300, // ارتفاع مناسب للفيديو
                            width: 200, // عرض مناسب للفيديو
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      ),
                      Icon(
                        _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 64,
                        color: Colors.white,
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                // حقل الوصف بدون إطار
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'أضف وصفًا...',
                    border: InputBorder.none, // إزالة الإطار
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}