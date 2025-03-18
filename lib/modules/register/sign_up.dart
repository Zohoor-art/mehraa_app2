import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/modules/signup2/sign_up2.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'dart:io';

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
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

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
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance.ref()
              .child('profiles/${userCredential.user!.uid}.jpg');
          await storageRef.putFile(File(_imageFile!.path));
          imageUrl = await storageRef.getDownloadURL();
        }

        // تخزين بيانات المستخدم في Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'storeName': storeNameController.text,
          'email': emailController.text,
          'profileImage': imageUrl,
        });

        await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUp2screen(userId: userCredential.user!.uid)),
        );
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
            Center(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.90,
                    height: MediaQuery.of(context).size.height * 0.70,
                    child: Card(
                      color: Colors.white,
                      shadowColor: Color(0xFF000000),
                      margin: EdgeInsets.only(bottom: 3.0),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 70.0, bottom: 40, right: 10, left: 10),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 64,
                                        backgroundImage: _imageFile != null
                                            ? FileImage(File(_imageFile!.path))
                                            : AssetImage('assets/images/2.jpg') as ImageProvider,
                                      ),
                                      Positioned(
                                        bottom: -10,
                                        left: 80,
                                        child: IconButton(
                                          onPressed: _pickImage,
                                          icon: const Icon(Icons.add_a_photo),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                defultTextFormField(
                                  controller: storeNameController,
                                  type: TextInputType.text,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'يرجى إدخال اسم المتجر';
                                    }
                                    return null;
                                  },
                                  label: 'اسم المتجر',
                                  prefix: Icons.home,
                                ),
                                SizedBox(height: 40.0),
                                defultTextFormField(
                                  controller: emailController,
                                  type: TextInputType.emailAddress,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'يرجى إدخال  الايميل';
                                    }
                                    return null;
                                  },
                                  label: 'البريد الالكتروني ',
                                  prefix: Icons.email,
                                ),
                                SizedBox(height: 20.0),
                                defultTextFormField(
                                  controller: passwordController,
                                  type: TextInputType.visiblePassword,
                                  ispassword: isPassword,
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
                                  label: 'كلمة المرور',
                                  prefix: Icons.lock,
                                  suffix: isPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  suffixPressed: () {
                                    setState(() {
                                      isPassword = !isPassword;
                                    });
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: GradientButton(
                                    onPressed: isLoading ? () {} : _submit,
                                    text: isLoading ? 'جارٍ التحميل...' : 'التحقق',
                                    width: 319,
                                    height: 67,
                                  ),
                                ),
                              ],
                            ),
                          ),
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