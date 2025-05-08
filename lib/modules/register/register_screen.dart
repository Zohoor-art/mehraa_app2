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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserLoggedIn();
    });
  }

  void checkUserLoggedIn() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      print('المستخدم مسجل مسبقاً: ${user.uid}');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }
    }
  }

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

      print("تم تسجيل الدخول بنجاح! UID: ${user.uid}");
      print("بيانات المستخدم: ${user.displayName}, ${user.email}");

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }

      return userCredential;
    } catch (e) {
      print("حدث خطأ أثناء تسجيل الدخول باستخدام Google: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("خطأ"),
            content: Text("فشل تسجيل الدخول:\n$e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("موافق"),
              ),
            ],
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.08,
                          child: GradientButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => HomeScreen()),
                                (route) => false,
                              );
                            },
                            text: 'المتابعة بدون تسجيل دخول',
                            fontSize: screenWidth < 400 ? 16 : 18,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        SizedBox(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.08,
                          child: GradientButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpscreen()),
                              );
                            },
                            text: 'انشاء حساب تجاري',
                            fontSize: screenWidth < 400 ? 16 : 18,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        SizedBox(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.08,
                          child: buildGoogleButton(
                            text: 'المتابعة بحساب جوجل',
                            fontSize: screenWidth < 400 ? 16 : 18,
                            onPressed: () async {
                              if (!isLoading) {
                                await signInWithGoogle();
                              }
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
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
                  SizedBox(height: screenHeight * 0.1),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: bottomImage(),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}