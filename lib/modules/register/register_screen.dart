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
    checkUserLoggedIn();
  }

  void checkUserLoggedIn() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed("HomeScreen");
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("User canceled the sign-in process.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);

      await firestore.collection('users').doc(userCredential.user?.uid).set({
        'uid': userCredential.user?.uid,
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'photoURL': userCredential.user?.photoURL,
      });

      await Firebase_Firestor().saveGoogleUser(userCredential.user!);

      print("User ID: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.error),
          content: Text("${AppLocalizations.of(context)!.loginFailed}\n${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
      return null;
    } finally {
      setState(() => isLoading = false);
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
            child: SizedBox(
              height: screenHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.2),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.08,
                            child: GradientButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => HomeScreen()),
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
                                Navigator.pushReplacement(
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
                                  UserCredential? userCredential = await signInWithGoogle();
                                  if (userCredential != null) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
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
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
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
                  ),
                  SizedBox(
                    height: screenHeight * 0.2,
                    child: bottomImage(),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
