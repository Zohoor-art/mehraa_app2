import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/utils/utils.dart';

class AddPostscreen extends StatefulWidget {
  const AddPostscreen({super.key});

  @override
  State<AddPostscreen> createState() => _AddPostscreenState();
}

class _AddPostscreenState extends State<AddPostscreen> {
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _file == null
    
    
        ? Container(
  color: MyColor.lightprimaryColor,
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'اضغط على الايقونة لتحميل منشورك',
          style: TextStyle(
            fontSize: 20, // يمكنك تعديل حجم الخط حسب الحاجة
            fontWeight: FontWeight.bold,
            color: Colors.black, // يمكنك تعديل اللون حسب الحاجة
          ),
        ),
        SizedBox(height: 10), // مسافة بين العنوان وزر التحميل
        IconButton(
          onPressed: () => selectImage(context),
          icon: Icon(Icons.upload, size: 50), // استخدم 'size' بدلاً من 'weight'
        ),
      ],
    ),
  ),
)
    : Scaffold(
      appBar: AppBar(
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
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'النشر الى',
          style: TextStyle(color: Color.fromARGB(255, 227, 194, 249)),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'نشر',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             CircleAvatar(
              backgroundImage: AssetImage('assets/images/1.jpg'),
              radius: 20, // يمكنك تعديل الحجم هنا حسب الرغبة
            ),
            // الصورة الثانية على اليسار
            
            // حقل النص في المنتصف
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ادخل الوصف',
                    border: InputBorder.none,
                    hintTextDirection: TextDirection.rtl 
                    // يمكنك تغيير الحدود
                  ),
                  maxLines: 8,
                ),
              ),
            ),
            SizedBox(
              height: 45,
              width: 45,
              child: AspectRatio(
                aspectRatio: 1, // جعلها مربع
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(_file!),
                      fit: BoxFit.cover,
                      alignment: FractionalOffset.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(8), // زوايا مستديرة
                  ),
                ),
              ),
            ),
            // صورة الأفاتار على اليمين
           
          ],
        ),
      ),
    );
  }
}