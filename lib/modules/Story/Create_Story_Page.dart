import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/shared/components/constants.dart';

class CreateStoryPage extends StatefulWidget {
  @override
  _CreateStoryPageState createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _caption = '';
  File? _selectedFile;
  String mediaType = 'text';
  Color _backgroundColor = Colors.white;
  bool _isUploading = false;

  final List<Color> _colors = [
    Colors.white,
    Colors.black,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.teal,
  ];

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final picker = ImagePicker();
    final pickedFile = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
        mediaType = isVideo ? 'video' : 'image';
      });
    }
  }

  Future<void> _showCameraOptions() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('📸 التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, isVideo: false);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('🎥 تسجيل فيديو'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, isVideo: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addStory() async {
    setState(() => _isUploading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      String? downloadUrl;

      if (_selectedFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}';
        final ref = _storage.ref().child('stories/$fileName');
        final uploadTask = ref.putFile(_selectedFile!);
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      final timestamp = Timestamp.now();
      final expirationTime = Timestamp.fromDate(DateTime.now().add(Duration(hours: 24)));

      await _firestore.collection('stories').add({
        'userId': user.uid,
        'mediaUrl': downloadUrl ?? '',
        'mediaType': mediaType,
        'caption': _caption,
        'backgroundColor': _backgroundColor.value,
        'timestamp': timestamp,
        'expirationTime': expirationTime,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      print('❌ Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ حدث خطأ أثناء النشر!')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  color: _selectedFile == null ? _backgroundColor : Colors.black,
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: _selectedFile != null
                        ? mediaType == 'video'
                            ? Icon(Icons.play_circle_fill, size: 120, color: Colors.white)
                            : Image.file(_selectedFile!, fit: BoxFit.contain)
                        : TextField(
                            decoration: InputDecoration.collapsed(hintText: '✍️ اكتب ستوريتك هنا...'),
                            style: TextStyle(
                              fontSize: 28,
                              color: _backgroundColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            maxLines: null,
                            textAlign: TextAlign.center,
                            onChanged: (value) => _caption = value,
                          ),
                  ),
                ),
              ),
              if (_selectedFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '📝 اضافة نص',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _caption = value,
                    maxLines: 3,
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _colors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _backgroundColor = color;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: _backgroundColor == color ? Colors.black : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showCameraOptions,
                          icon: Icon(Icons.camera_alt, size: 16),
                          label: Text('كاميرا', style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickMedia(ImageSource.gallery),
                          icon: Icon(Icons.image, size: 16),
                          label: Text('صورة', style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
                          icon: Icon(Icons.videocam, size: 16),
                          label: Text('فيديو', style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          onPressed: _isUploading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('📤 جاري رفع الستوري...'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  _addStory();
                                },
                          child: _isUploading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    ),
                                    SizedBox(width: 8),
                                    Text('🔄 جاري النشر...',
                                        style: TextStyle(fontSize: 12, color: Colors.white)),
                                  ],
                                )
                              : Text('📤 نشر',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor.darkPurpleColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isUploading)
            Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
    
  }
}
