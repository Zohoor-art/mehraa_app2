import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/utils/utils.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class AddPostScreens extends StatefulWidget {
  final String uid;
  final String username;
  final String? profileImage;

  const AddPostScreens({
    Key? key,
    required this.uid,
    required this.username,
    this.profileImage,
  }) : super(key: key);

  @override
  State<AddPostScreens> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreens> {
  Uint8List? _file;
  final TextEditingController captionController = TextEditingController();

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }

  selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Create Post'),
        children: [
          SimpleDialogOption(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Take a photo"),
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
              child: Text("Choose from gallery"),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.gallery);
              setState(() {
                _file = file;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> uploadPost() async {
    if (_file != null && captionController.text.isNotEmpty) {
      String imageBase64 = base64Encode(_file!); // تحويل الصورة إلى Base64
      String postId = Uuid().v1(); // معرف فريد للمنشور

      // تخزين المنشور في Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'likes': [],
        'description': captionController.text,
        'username': widget.username,
        'postId': postId,
        'datePublished': Timestamp.now(),
        'uid': widget.uid,
        'postUrl': imageBase64,
        'profileImage': widget.profileImage,
      });

      setState(() {
        _file = null;
        captionController.clear();
      });

      showSnackBar('Post uploaded successfully!', context);
    } else {
      setState(() {
        _file = null;
        captionController.clear();
      });
      showSnackBar('Please add an image and caption!', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _file == null
        ? Center(
            child: IconButton(
              onPressed: () => selectImage(context),
              icon: Icon(Icons.upload),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: MyColor.lightprimaryColor,
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    _file = null; // إعادة تعيين الصورة
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
              title: const Text('Post to'),
              actions: [
                TextButton(
                  onPressed: uploadPost, // استدعاء uploadPost بشكل صحيح
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: widget.profileImage != null &&
                              widget.profileImage!.isNotEmpty
                          ? NetworkImage(widget.profileImage!)
                          : AssetImage('assets/avatar.jpeg') as ImageProvider,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        controller: captionController,
                        decoration: InputDecoration(
                          hintText: 'Write caption...',
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    if (_file != null)
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: AspectRatio(
                          aspectRatio: 487 / 451,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: MemoryImage(_file!),
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
  }
}