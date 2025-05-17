import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mehra_app/shared/appbar.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/firebase/firestore_methods.dart';
import 'package:mehra_app/shared/utils/utils.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';

class CreateReelScreen extends StatefulWidget {
  final String videoPath;

  const CreateReelScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  late VideoPlayerController _controller;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  DocumentReference? _userRef;
    String selectedRegionName = ''; // اسم المنطقة (إجباري)
String? detailedLocationUrl;    // رابط Google Maps (يدوي أو من الخريطة)
GeoPoint? selectedCoords;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _fetchUserReference();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  Future<void> _fetchUserReference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _userRef!.get();
        return {
          'uid': user.uid,
          'storeName': userDoc['storeName'] ?? 'متجر غير معروف',
          'profileImage': userDoc['profileImage'] ?? 'https://example.com/default.png',
        };
      } catch (e) {
        return {
          'uid': user.uid,
          'storeName': 'متجر غير معروف',
          'profileImage': 'https://example.com/default.png',
        };
      }
    }
    return {
      'uid': '',
      'storeName': 'متجر غير معروف',
      'profileImage': 'https://example.com/default.png',
    };
  }

  void _uploadReel() async {
    if (_controller.value.duration.inSeconds > 60) {
      showSnackBar('يجب أن تكون مدة الفيديو أقل من دقيقة واحدة', context);
      return;
    }

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("جاري نشر المنشور..."),
          ],
        ),
      ),
    );

    try {
      final userData = await _fetchUserDetails();
       
    final location = userData['location'] ?? '';
    final locationUrl = userData['locationUrl']; // ممكن يكون null
    
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        Uint8List(0),
        userData['uid'],
        userData['storeName'],
        userData['profileImage'],
        videoPath: widget.videoPath,
        userRef: _userRef,
        context: context,
        isVideo: true, 
        location: selectedRegionName,
        locationUrl: detailedLocationUrl, // رابط Google Maps (يدوي أو من الخريطة)
         // إحداثيات الموقع (اختياري)
      );

      Navigator.pop(context); // إغلاق Dialog

      if (res.contains('بنجاح')) {
        showSnackBar('تم نشر الريل بنجاح', context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
      } else {
        showSnackBar(res, context);
      }
    } catch (e) {
      Navigator.pop(context); // إغلاق Dialog عند الخطأ
      showSnackBar('حدث خطأ: $e', context);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(
        title: const Text('إنشاء ريل'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ElevatedButton.icon(
              onPressed: _uploadReel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text('نشر', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading) const LinearProgressIndicator(),
              const SizedBox(height: 20),

              // عرض الفيديو بشكل أنيق
              if (_controller.value.isInitialized)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_controller),
                        if (!_controller.value.isPlaying)
                          IconButton(
                            icon: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _controller.play();
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // حقل الوصف
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'أضف وصفًا للريل...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // معلومات عن الفيديو
              if (_controller.value.isInitialized)
                Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 8),
                    Text(
                      '${_controller.value.duration.inSeconds} ثانية',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
