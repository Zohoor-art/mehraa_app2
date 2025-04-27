import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/models/firebase/auth_methods.dart';
import 'package:mehra_app/modules/register/email_verification_screen.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class SignUpscreen extends StatefulWidget {
  const SignUpscreen({super.key});

  @override
  State<SignUpscreen> createState() => _SignUpscreenState();
}

class _SignUpscreenState extends State<SignUpscreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController storeNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isPassword = true;
  bool isLoading = false;
  XFile? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    storeNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    storeNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _imageBytes != null) {
      setState(() => isLoading = true);

      final authMethods = AuthMethods();
      final result = await authMethods.startSignUpProcess(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        storeName: storeNameController.text.trim(),
        file: _imageBytes!,
      );

      setState(() => isLoading = false);

      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              userId: result['userId'],
              email: emailController.text.trim(),
              storeName: storeNameController.text.trim(),
              profileImage: result['profileImage'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار صورة للملف الشخصي'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(color: MyColor.lightprimaryColor),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/bottom.png',
                fit: BoxFit.cover,
                width: screenWidth,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: screenHeight * 0.1,
                ),
                child: Container(
                  width: isSmallScreen ? screenWidth * 0.95 : screenWidth * 0.9,
                  margin: EdgeInsets.only(bottom: screenHeight * 0.12),
                  child: Card(
                    color: Colors.white,
                    shadowColor: const Color(0xFF000000),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: isSmallScreen ? 50 : 60,
                                  backgroundImage: _imageFile != null
                                      ? FileImage(File(_imageFile!.path))
                                      : const AssetImage('assets/images/profile.png') as ImageProvider,
                                ),
                                IconButton(
                                  onPressed: _pickImage,
                                  icon: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: MyColor.purpleColor,
                                    size: isSmallScreen ? 24 : 28,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            defultTextFormField(
                              controller: storeNameController,
                              label: 'اسم المتجر',
                              prefix: Icons.home,
                              type: TextInputType.text,
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى ادخال اسم المتجر';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            defultTextFormField(
                              controller: emailController,
                              label: 'البريد الالكتروني',
                              prefix: Icons.email,
                              type: TextInputType.emailAddress,
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى ادخال البريد الالكتروني';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                  return 'البريد الإلكتروني غير صالح';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            defultTextFormField(
                              controller: passwordController,
                              type: TextInputType.visiblePassword,
                              ispassword: isPassword,
                              label: 'كلمة المرور',
                              prefix: Icons.lock,
                              suffix: isPassword ? Icons.visibility_off : Icons.visibility,
                              suffixPressed: () {
                                setState(() {
                                  isPassword = !isPassword;
                                });
                              },
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال كلمة المرور';
                                }
                                if (value.length < 8) {
                                  return 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            GradientButton(
                              onPressed: _submitForm,
                              text: isLoading ? 'جارٍ التحميل...' : 'المتابعة',
                              width: isSmallScreen ? screenWidth * 0.8 : 319,
                              height: isSmallScreen ? 50 : 67,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
