import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/login/login_screen.dart';
import 'package:mehra_app/modules/reels/home.dart';
import 'package:mehra_app/modules/register/sign_up.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  // التحقق مما إذا كان المستخدم قد سجل الدخول
  void checkUserLoggedIn() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed("HomeScreen");
    }
  }

  // تسجيل الدخول باستخدام حساب Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      setState(() {
        isLoading = true; // بدء التحميل
      });

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("User canceled the sign-in process.");
        return null; // المستخدم ألغى العملية
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول مع Firebase
      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);

      // إضافة بيانات المستخدم إلى Firestore
      await firestore.collection('users').doc(userCredential.user?.uid).set({
        'uid': userCredential.user?.uid,
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'photoURL': userCredential.user?.photoURL,
      });

      print("User ID: ${userCredential.user?.uid}");
      return userCredential; 
    } catch (e) {
      print("Error during Google Sign-In: ${e.toString()}");
      // إظهار رسالة الخطأ للمستخدم
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("خطأ"),
          content: Text("فشل تسجيل الدخول، يرجى المحاولة مرة أخرى. \n${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("حسناً"),
            ),
          ],
        ),
      );
      return null;
    } finally {
      setState(() {
        isLoading = false; // إنهاء التحميل
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  GradientButton(
           onPressed: () {
                      MaterialPageRoute(builder: (context) => HomeScreen());
                    },

                    text: 'المتابعة بدون تسجيل دخول',
                    width: 336,
                    height: 69,
                    fontSize: 30,
                  ),
                  SizedBox(height: 60),
                  GradientButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpscreen()),
                      );
                    },
                    text: 'انشاء حساب تجاري',
                    width: 336,
                    height: 69,
                  ),
                  SizedBox(height: 60),
                  buildGoogleButton(
                    text: 'المتابعة بحساب جوجل',
                    onPressed: () async {
                      if (!isLoading) {
                        UserCredential? userCredential = await signInWithGoogle();
                        if (userCredential != null) {
                          Navigator.of(context).pushNamedAndRemoveUntil("HomeScreen", (route) => false);
                          print("User signed in successfully!");
                        } else {
                          print("Failed to sign in with Google.");
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginScreen()), // استبدل  باسم صفحتك
                        );
                      },
                      child: Text(
                        'لديك حساب! الدخول بالحساب',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: bottomImage(),
          ),
          if (isLoading) // عرض مؤشر التحميل إذا كانت حالة التحميل True
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}