// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mehra_app/models/firebase/firestore.dart';
// import 'package:mehra_app/models/firebase/storge.dart';
// import 'package:mehra_app/modules/homePage/home_screen.dart';

// class AddPostTextScreen extends StatefulWidget {
//   final File _file; // تعديل لجعل المتغير final
//   const AddPostTextScreen(this._file, {super.key});

//   @override
//   State<AddPostTextScreen> createState() => _AddPostTextScreenState();
// }

// class _AddPostTextScreenState extends State<AddPostTextScreen> {
//   final caption = TextEditingController();
//   final location = TextEditingController();
//   bool isLoading = false;

//   @override
//   void dispose() {
//     caption.dispose();
//     location.dispose();
//     super.dispose();
//   }

//   void _sharePost() async {
//     if (caption.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Caption cannot be empty')),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // String postUrl = await StorageMethod().uploadImageToStorage('post', widget._file as Uint8List);
//       await Firebase_Firestor().CreatePost(
//         postImage: postUrl,
//         caption: caption.text,
//         location: location.text,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Post shared successfully!')),
//       );

//       // العودة إلى الشاشة الرئيسية بعد تأخير
//       Future.delayed(Duration(seconds: 1), () {
//         if (mounted) {
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => HomeScreen()), // استبدل بـ HomeScreen الخاصة بك
//             (Route<dynamic> route) => false,
//           );
//         }
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Scaffold(
//           appBar: AppBar(
//             iconTheme: IconThemeData(color: Colors.black),
//             backgroundColor: Colors.white,
//             elevation: 0,
//             title: Text('New post', style: TextStyle(color: Colors.black)),
//             actions: [
//               GestureDetector(
//                 onTap: _sharePost,
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 10.w),
//                   child: Text('Share', style: TextStyle(color: Colors.blue, fontSize: 15.sp)),
//                 ),
//               ),
//             ],
//           ),
//           body: SafeArea(
//             child: Padding(
//               padding: EdgeInsets.only(top: 10.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 65.w,
//                           height: 65.h,
//                           decoration: BoxDecoration(
//                             color: Colors.amber,
//                             image: DecorationImage(
//                               image: FileImage(widget._file),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10.w),
//                         SizedBox(
//                           width: 280.w,
//                           height: 60.h,
//                           child: TextField(
//                             controller: caption,
//                             decoration: InputDecoration(hintText: 'Write a caption ...', border: InputBorder.none),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10.w),
//                     child: SizedBox(
//                       width: 280.w,
//                       height: 30.h,
//                       child: TextField(
//                         controller: location,
//                         decoration: InputDecoration(hintText: 'Add location', border: InputBorder.none),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (isLoading)
//           Container(
//             color: Colors.black.withOpacity(0.5),
//             child: Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             ),
//           ),
//       ],
//     );
//   }
// }