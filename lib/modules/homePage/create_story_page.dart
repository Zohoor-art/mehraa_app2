import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/shared/components/constants.dart';

class CreateStoryPage extends StatefulWidget {
  @override
  _CreateStoryPageState createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  XFile? _media;
  bool _isTextStory = false;
  bool _isVideo = false;
  Color _storyColor = Colors.white; // لون الاستوري الافتراضي

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickVideo(source: ImageSource.gallery);
    if (media == null) {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _media = image;
        _isTextStory = false;
        _isVideo = false;
      });
    } else {
      setState(() {
        _media = media;
        _isTextStory = false;
        _isVideo = true;
      });
    }
  }

  void _selectColor(Color color) {
    setState(() {
      _storyColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FF),
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 55,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 0),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: MyColor.blueColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'إنشاء استوري',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 12, 12, 12),
                        fontSize: 25,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      String title = _titleController.text;
                      print('استوري جديد: $title, وسائط: ${_media?.path}, نص: ${_isTextStory ? title : ''}');
                      Navigator.pop(context);
                    },
                    child: Text(
                      'نشر',
                      style: TextStyle(color: MyColor.blueColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text('استوري نص فقط'),
                    value: _isTextStory,
                    onChanged: (bool value) {
                      setState(() {
                        _isTextStory = value;
                        if (value) {
                          _media = null; // إذا كان نص فقط، لا نريد وسائط
                          _isVideo = false; // تأكد من أنه ليس فيديو
                        }
                      });
                    },
                  ),
                  if (_isTextStory) ...[
                    Text('اختر لون الاستوري:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () => _selectColor(Colors.red),
                          child: Container(
                            width: 30,
                            height: 30,
                            color: Colors.red,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _selectColor(Colors.green),
                          child: Container(
                            width: 30,
                            height: 30,
                            color: Colors.green,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _selectColor(Colors.blue),
                          child: Container(
                            width: 30,
                            height: 30,
                            color: Colors.blue,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _selectColor(Colors.yellow),
                          child: Container(
                            width: 30,
                            height: 30,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _storyColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _titleController.text.isEmpty ? 'نص الاستوري' : _titleController.text,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  if (!_isTextStory) ...[
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(10),
                          image: _media != null && !_isVideo
                              ? DecorationImage(
                                  image: FileImage(File(_media!.path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _media == null
                            ? Center(
                                child: Text(
                                  'اختر صورة أو فيديو',
                                  style: TextStyle(color: Colors.grey, fontSize: 20),
                                ),
                              )
                            : _isVideo
                                ? Center(
                                    child: Text(
                                      'فيديو مختار',
                                      style: TextStyle(color: Colors.grey, fontSize: 20),
                                    ),
                                  )
                                : null,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _titleController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'أدخل عنوان الاستوري',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}