import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mehra_app/models/userModel.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;
  final String userId;

  const EditProfileScreen({super.key, required this.currentData, required this.userId, required Users user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.currentData['storeName']);
    _descriptionController = TextEditingController(text: widget.currentData['description']);
    _locationController = TextEditingController(text: widget.currentData['location']);
    super.initState();
  }

  Future<void> _pickImageWithConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تعديل الصورة الشخصية"),
        content: const Text("هل تريد تعديل صورة الملف الشخصي؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("لا")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("نعم")),
        ],
      ),
    );

    if (confirm == true) {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profileImages')
          .child('${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  void _saveProfile() async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحفظ'),
        content: const Text('هل أنت متأكد أنك تريد حفظ التعديلات؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('موافق')),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isSaving = true);

      String? imageUrl = widget.currentData['profileImage'];
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'storeName': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'profileImage': imageUrl,
      });

      if (context.mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, true); // رجعنا للصفحة الرئيسية بعد الحفظ
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل البروفايل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("جاري الحفظ..."),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none, 
                      alignment: Alignment.bottomCenter,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : NetworkImage(widget.currentData['profileImage'] ?? '') as ImageProvider,
                        ),
                    Positioned(
  bottom: 0,
  right: -10, // تخليها تطلع شوية خارج الصورة
  child: GestureDetector(
    onTap: _pickImageWithConfirmation,
    child: Container(
      padding: const EdgeInsets.all(6), // أصغر
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFFBA68C8)], // بنفسجي متدرج
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.edit,
        color: Colors.white,
        size: 18, // أصغر
      ),
    ),
  ),
),


                      ],
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'اسم المتجر'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'الوصف'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'الموقع'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
