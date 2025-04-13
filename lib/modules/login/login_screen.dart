import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // استيراد Firebase Auth
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isPassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true; // بدء التحميل
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // إذا نجح تسجيل الدخول، انتقل إلى الصفحة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen()), // استبدل ReelsPage باسم صفحتك
        );
      } on FirebaseAuthException catch (e) {
        // التعامل مع الأخطاء
        String message = "حدث خطأ";
        if (e.code == 'user-not-found') {
          message = 'لا يوجد مستخدم مسجل بهذا البريد الإلكتروني.';
        } else if (e.code == 'wrong-password') {
          message = 'كلمة المرور غير صحيحة.';
        }
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'خطأ',
          desc: message,
          btnOkOnPress: () {},
          btnOkColor: Colors.red,
        ).show();
      } finally {
        setState(() {
          isLoading = false; // إيقاف التحميل
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
                    height: MediaQuery.of(context).size.height * 0.55,
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
                                top: 50.0, bottom: 40, right: 10, left: 10),
                            child: Column(
                              children: [
                                SizedBox(height: 20.0),
                                defultTextFormField(
                                  controller: emailController,
                                  label: 'البريد الالكتروني',
                                  prefix: Icons.email,
                                  type: TextInputType.emailAddress,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'يرجى إدخال  الايميل';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 30.0),
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
                                SizedBox(height: 30),
                                Center(
                                  child: GradientButton(
                                    onPressed:
                                        _login, // استدعاء دالة تسجيل الدخول
                                    text: "الدخول",
                                    width: 319,
                                    height: 67,
                                  ),
                                ),
                                SizedBox(height: 30),
                                Expanded(
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterScreen()), // استبدل ReelsPage باسم صفحتك
                                        );
                                      },
                                      child: Text(
                                        ' ليس لديك حساب ! انشاء حساب',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      )),
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
