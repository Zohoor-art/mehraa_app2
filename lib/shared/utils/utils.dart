import 'dart:typed_data'; // تأكد من استيراد هذا
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> PicImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  
  if (file != null) {
    return await file.readAsBytes();  // تأكد من استخدام await هنا
  }
  
  print('No image selected');
  return null; // إرجاع null في حالة عدم تحديد الصورة
}
showSnackBar(String content,BuildContext context){
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(content)),
    );
}