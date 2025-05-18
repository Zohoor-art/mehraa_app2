import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mehra_app/models/firebase/firestore.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/login/login_screen.dart';
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
  }

  // التحقق مما إذا كان المستخدم قد سجل الدخول
  void checkUserLoggedIn() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed("HomeScreen");
    }
  }

// في ملف تسجيل الدخول
  Future<UserCredential?> signInWithGoogle() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("تم إلغاء عملية تسجيل الدخول من قبل المستخدم.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'profileImage': user.photoURL,
        'contactNumber': null,
        'days': null,
        'description': null,
        'followers': [],
        'following': [],
        'hours': null,
        'location': null,
        'storeName': null,
        'workType': null,
        'isCommercial': false,
        'provider': user.providerData.isNotEmpty
            ? user.providerData[0].providerId
            : null,
        'lastMessageTime': null,
      }, SetOptions(merge: true));

      await Firebase_Firestor().saveGoogleUser(user);

      print("User ID: ${user.uid}");
      return userCredential;
    } catch (e) {
      print("حدث خطأ أثناء تسجيل الدخول باستخدام Google: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("خطأ"),
          content: Text("فشل تسجيل الدخول:\n$e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("موافق"),
            ),
          ],
        ),
      );
      return null;
    } finally {
      setState(() => isLoading = false);
    }
  }
// Future<UserCredential?> signInWithGoogle() async {
//   try {
//     setState(() => isLoading = true);

//     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//     if (googleUser == null) return null;

//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final UserCredential userCredential =
//         await firebaseAuth.signInWithCredential(credential);

//     // حفظ بيانات المستخدم باستخدام Firebase_Firestor
//     await Firebase_Firestor().saveGoogleUser(userCredential.user!);

//     return userCredential;
//   } catch (e) {
//     print("Error during Google Sign-In: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('فشل تسجيل الدخول: ${e.toString()}')),
//     );
//     return null;
//   } finally {
//     setState(() => isLoading = false);
//   }
// }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
      body: Stack(
        children: [
          // محتوى الصفحة
          SingleChildScrollView(
            child: SizedBox(
              height: screenHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // المساحة العلوية
                  SizedBox(height: screenHeight * 0.2),

                  // الأزرار الرئيسية
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // زر المتابعة بدون تسجيل
                          SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.08,
                            child: GradientButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                );
                              },
                              text: 'المتابعة بدون تسجيل دخول',
                              fontSize: screenWidth < 400 ? 16 : 18,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),

                          // زر إنشاء حساب تجاري
                          SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.08,
                            child: GradientButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpscreen()),
                                );
                              },
                              text: 'انشاء حساب تجاري',
                              fontSize: screenWidth < 400 ? 16 : 18,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),

                          // زر جوجل
                          SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.08,
                            child: buildGoogleButton(
                              text: 'المتابعة بحساب جوجل',
                              fontSize: screenWidth < 400 ? 16 : 18,
                              onPressed: () async {
                                if (!isLoading) {
                                  UserCredential? userCredential =
                                      await signInWithGoogle();
                                  if (userCredential != null) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            "HomeScreen", (route) => false);
                                    print("User signed in successfully!");
                                  } else {
                                    print("Failed to sign in with Google.");
                                  }
                                }
                              },
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          // زر لديك حساب
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              'لديك حساب! الدخول بالحساب',
                              style: TextStyle(
                                fontSize: screenWidth < 400 ? 16 : 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // الصورة السفلية
                  SizedBox(
                    height: screenHeight * 0.2,
                    child: bottomImage(),
                  ),
                ],
              ),
            ),
          ),

          // مؤشر التحميل
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
