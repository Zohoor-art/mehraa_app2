import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

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
  String mediaType = 'text'; // default نوع محتوى نصي

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

  Future<void> _addStory() async {
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
      final expirationTime = Timestamp.fromDate(DateTime.now().add(Duration(hours: 24))); // 24 ساعة بعد النشر

      await _firestore.collection('stories').add({
        'userId': user.uid,
        'mediaUrl': downloadUrl ?? '',
        'mediaType': mediaType,
        'caption': _caption,
        'timestamp': timestamp,

        'expirationTime': Timestamp.now().toDate().add(Duration(hours: 24) )// حفظ وقت انتهاء الستوري
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم إضافة الستوري بنجاح!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إضافة الستوري!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة استوري')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'اكتب تعليقًا (اختياري)'),
                onChanged: (value) => _caption = value,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              if (_selectedFile != null)
                mediaType == 'video'
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.black12,
                        child: Icon(Icons.play_circle_fill, size: 60),
                      )
                    : Image.file(_selectedFile!, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.gallery),
                icon: Icon(Icons.image),
                label: Text('اختر صورة'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
                icon: Icon(Icons.video_library),
                label: Text('اختر فيديو'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addStory,
                child: Text('📤 نشر الاستوري'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
