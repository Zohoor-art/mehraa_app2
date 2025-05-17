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
    Colors.black,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pinkAccent,
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
      final expirationTime =
          Timestamp.fromDate(DateTime.now().add(Duration(hours: 24)));

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

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
        title: Text('إنشاء يومية', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  color:
                      _selectedFile == null ? _backgroundColor : Colors.black,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: _selectedFile != null
                        ? mediaType == 'video'
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_circle_fill,
                                      size: 80, color: Colors.white),
                                  SizedBox(height: 10),
                                  Text('فيديو',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
                                ],
                              )
                            : Image.file(_selectedFile!, fit: BoxFit.contain)
                        : TextField(
                            decoration: InputDecoration.collapsed(
                              hintText: '✍️ اكتب يوميتك هنا...',
                              hintStyle: TextStyle(
                                fontSize: isSmallScreen ? 22 : 28,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 22 : 28,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '📝 اضافة نص',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) => _caption = value,
                    maxLines: 3,
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
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
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ],
                                border: Border.all(
                                  color: _backgroundColor == color
                                      ? MyColor.darkPurpleColor
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.camera_alt,
                          label: 'كاميرا',
                          onPressed: _showCameraOptions,
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildActionButton(
                          icon: Icons.image,
                          label: 'صورة',
                          onPressed: () => _pickMedia(ImageSource.gallery),
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildActionButton(
                          icon: Icons.videocam,
                          label: 'فيديو',
                          onPressed: () =>
                              _pickMedia(ImageSource.gallery, isVideo: true),
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildUploadButton(isSmallScreen: isSmallScreen),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('جاري رفع المحتوى...',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isSmallScreen,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: MyColor.darkPurpleColor,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: MyColor.darkPurpleColor),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallScreen ? 16 : 18),
          SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
        ],
      ),
    );
  }

  Widget _buildUploadButton({required bool isSmallScreen}) {
    return ElevatedButton(
      onPressed: _isUploading
          ? null
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📤 جاري رفع اليومية...'),
                  duration: Duration(seconds: 2),
                ),
              );
              _addStory();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColor.darkPurpleColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 24,
          vertical: isSmallScreen ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: _isUploading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 8),
                Text('جاري النشر...', style: TextStyle(fontSize: 14)),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload, size: isSmallScreen ? 16 : 18),
                SizedBox(width: 6),
                Text('نشر',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
              ],
            ),
    );
  }
}
