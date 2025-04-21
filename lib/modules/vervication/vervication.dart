import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/modules/vervication/InputScreen.dart';
import 'package:mehra_app/shared/components/constants.dart';

class VervicationScreen extends StatefulWidget {
  const VervicationScreen({super.key});

  @override
  State<VervicationScreen> createState() => _VervicationScreenState();
}

class _VervicationScreenState extends State<VervicationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<bool> _selectedCircles = List.filled(12, false);
  List<String> _enteredNumbers = List.filled(12, '');
  String verificationCode = ""; // هذا سيتضمن كود التحقق المرسل
  String profileImageUrl = ""; // رابط صورة البروفايل

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // الحصول على رابط الصورة من Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        profileImageUrl = userDoc['profileImage'] ?? ''; // تأكد من أن 'profileImage' هو الاسم الصحيح في Firestore
      });
    }
  }

  void _onClear() {
    setState(() {
      _controller.clear();
      _selectedCircles = List.filled(12, false);
      _enteredNumbers = List.filled(12, '');
    });
  }

  void _onCirclePressed(int index) {
    setState(() {
      _selectedCircles[index] = !_selectedCircles[index];
    });
  }

  void _onNumberPressed(String number) {
    setState(() {
      for (int i = 0; i < _enteredNumbers.length; i++) {
        if (_enteredNumbers[i].isEmpty) {
          _enteredNumbers[i] = number;
          _selectedCircles[i] = true;
          break;
        }
      }
      // تحقق من الكود إذا تم إدخال الرقم الأخير
      if (_enteredNumbers.every((element) => element.isNotEmpty)) {
        _verifyCode();
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      for (int i = _enteredNumbers.length - 1; i >= 0; i--) {
        if (_enteredNumbers[i].isNotEmpty) {
          _enteredNumbers[i] = '';
          _selectedCircles[i] = false;
          break;
        }
      }
    });
  }

  Future<void> _verifyCode() async {
    String enteredCode = _enteredNumbers.join('');

    // هنا نتحقق من كود التحقق
    if (enteredCode == verificationCode) {
      // إذا كان الكود صحيحًا، انتقل إلى صفحة تسجيل الدخول الثانية
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => SignUp2screen()
      //), // تأكد من استبدالها بالصفحة الصحيحة
      // );
    } else {
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('كود التحقق غير صحيح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Container(
              color: MyColor.lightprimaryColor,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/bottom.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: 430,
                height: 268,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : AssetImage('assets/images/1.jpg') as ImageProvider,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'أدخل رمز التحقق',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(12, (index) {
                            return GestureDetector(
                              onTap: () => _onCirclePressed(index),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 2), // تقليل الفجوة بين الدوائر
                                width: 20, // تصغير حجم الدائرة
                                height: 20, // تصغير حجم الدائرة
                                decoration: BoxDecoration(
                                  gradient: _selectedCircles[index]
                                      ? LinearGradient(
                                          colors: [
                                            Color(0xFF4423B1),
                                            Color(0xFFA02D87),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: _selectedCircles[index]
                                      ? null
                                      : Color(0xFFE4E4E4),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: _selectedCircles[index]
                                      ? SizedBox()
                                      : Text(
                                          _enteredNumbers[index],
                                          style: TextStyle(
                                            color: MyColor.purpleColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 20),
                      // تم حذف زر "تحقق من الكود"
                    ],
                  ),
                ),
              ),
            ),
            NumberInputScreen(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
              enteredNumbers: _enteredNumbers,
            ),
          ],
        ),
      ),
    );
  }
}