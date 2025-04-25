import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/modules/homePage/add_reels.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/firebase/firestore_methods.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/utils/utils.dart';

class AddPostscreen extends StatefulWidget {
  const AddPostscreen({super.key});

  @override
  State<AddPostscreen> createState() => _AddPostscreenState();
}

class _AddPostscreenState extends State<AddPostscreen> {
  Uint8List? _file;
  String? _videoPath;
  VideoPlayerController? _controller;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  DocumentReference? _userRef; // سيحتوي على مرجع مستند المستخدم

  @override
  void initState() {
    super.initState();
    _fetchUserReference();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _fetchUserReference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    }
  }

  void postImage(String uid, String storename, String profileImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        storename,
        profileImage,
        videoPath: _videoPath,
        userRef: _userRef, // إضافة مرجع المستخدم
        context: context, isVideo: true,
      );

      if (res == 'تم نشر الصورة بنجاح') {
        setState(() {
          _isLoading = false;
        });
        showSnackBar('تم النشر', context);
        clearImage();
      } else {
        showSnackBar(res, context);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  Future<void> pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoPath = pickedFile.path;
        _controller = VideoPlayerController.file(File(_videoPath!))
          ..initialize().then((_) {
            setState(() {});
          });
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateReelScreen(videoPath: _videoPath!),
        ),
      );
    }
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        return {
          'uid': user.uid,
          'storeName': userDoc['storeName'] ?? 'متجر غير معروف',
          'profileImage': userDoc['profileImage'] ?? 'https://img.icons8.com/material/344/user-male-circle--v1.png',
        };
      }
    }
    return {
      'uid': '',
      'storeName': 'متجر غير معروف',
      'profileImage': 'https://img.icons8.com/material/344/user-male-circle--v1.png',
    };
  }

  selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('انشاء منشور'),
        children: [
          SimpleDialogOption(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("التقط صورة"),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.camera);
              setState(() {
                _file = file;
              });
            },
          ),
          SimpleDialogOption(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("اختر من المعرض"),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.gallery);
              setState(() {
                _file = file;
              });
            },
          ),
          SimpleDialogOption(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("اختر فيديو"),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await pickVideo();
            },
          ),
          SimpleDialogOption(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("الغاء"),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void clearImage() {
    setState(() {
      _file = null;
      _videoPath = null;
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final userData = snapshot.data ?? {
          'uid': '',
          'storeName': 'متجر غير معروف',
          'profileImage': 'https://img.icons8.com/material/344/user-male-circle--v1.png',
        };

        return _file == null && _videoPath == null
            ? Container(
                color: MyColor.lightprimaryColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'اضغط على الايقونة لتحميل منشورك',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade400,
                                  Colors.purple.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              onPressed: () => selectImage(context),
                              icon: Icon(Icons.upload, size: 50, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            child: Text(
                              'رفع',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Text('النشر الى'),
                  actions: [
                    TextButton(
                      onPressed: () => postImage(
                        userData['uid'],
                        userData['storeName'],
                        userData['profileImage'],
                      ),
                      child: Text('نشر'),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  child: Column(
                    children: [
                      _isLoading
                          ? LinearProgressIndicator()
                          : Padding(padding: EdgeInsets.only(top: 0)),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userData['profileImage']),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  hintText: 'ادخل الوصف',
                                  border: InputBorder.none,
                                ),
                                maxLines: 8,
                              ),
                            ),
                          ),
                          if (_file != null)
                            SizedBox(
                              height: 45,
                              width: 45,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(_file!),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          if (_videoPath != null && _controller != null && _controller!.value.isInitialized)
                            Container(
                              height: 150,
                              width: 150,
                              child: VideoPlayer(_controller!),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}