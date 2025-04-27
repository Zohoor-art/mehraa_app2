import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            Center( // تم إضافة Center هنا لجعل المحتوى في المنتصف
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  width: isSmallScreen ? screenWidth * 0.95 : screenWidth * 0.9,
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: Card(
                    color: Colors.white,
                    shadowColor: Color(0xFF000000),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defultTextFormField(
                              controller: emailController,
                              label: 'البريد الالكتروني',
                              prefix: Icons.email,
                              type: TextInputType.emailAddress,
                              validate: (value) {
                                if (value!.isEmpty) return 'يرجى إدخال الايميل';
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            defultTextFormField(
                              controller: passwordController,
                              type: TextInputType.visiblePassword,
                              ispassword: isPassword,
                              validate: (value) {
                                if (value!.isEmpty) return 'يرجى إدخال كلمة المرور';
                                if (value.length < 8) return 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل';
                                if (!RegExp(r'[A-Z]').hasMatch(value)) return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
                                if (!RegExp(r'[0-9]').hasMatch(value)) return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
                                return null;
                              },
                              label: 'كلمة المرور',
                              prefix: Icons.lock,
                              suffix: isPassword ? Icons.visibility_off : Icons.visibility,
                              suffixPressed: () => setState(() => isPassword = !isPassword),
                            ),
                            SizedBox(height: 24),
                            GradientButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);
                                  try {
                                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => HomeScreen()),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.bottomSlide,
                                      title: 'خطأ',
                                      desc: e.message ?? 'حدث خطأ أثناء تسجيل الدخول',
                                      btnOkOnPress: () {},
                                    ).show();
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                              text: "الدخول",
                              width: isSmallScreen ? screenWidth * 0.85 : screenWidth * 0.8,
                              height: 50,
                            ),
                            SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                                );
                              },
                              child: Text(
                                'ليس لديك حساب ! انشاء حساب',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.black,
                                ),
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
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(MyColor.purpleColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}