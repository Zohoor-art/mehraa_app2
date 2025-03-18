import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mehra_app/modules/register/sign_up.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Initialize GoogleSignIn with the client ID
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          'AIzaSyA6w-8lYiWXcksdEETpYBtSgwO_SboNhDM.apps.googleusercontent.com',
    );

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    // Print the error for debugging
    print("Error during Google Sign-In: $e");
    return null; // Return null if there's an error
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                    onPressed: () {},
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
                        MaterialPageRoute(
                            builder: (context) =>
                                SignUpscreen()), // استبدل ReelsPage باسم صفحتك
                      );
                    },
                    text: 'انشاء حساب تجاري ',
                    width: 336,
                    height: 69,
                  ),
                  SizedBox(height: 60),
                  buildGoogleButton(
                    text: 'المتابعة بحساب جوجل',
                    onPressed: () async {
                      UserCredential? userCredential = await signInWithGoogle();
                      if (userCredential != null) {
                        // Navigate to the next screen or show success message
                        print("User signed in successfully!");
                      } else {
                        // Show an error message
                        print("Failed to sign in with Google.");
                      }
                    },
                  ),
                  SizedBox(height: 60),
                  Text(
                    'ليس لديك حساب! انشئ حساب',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: bottomImage())
        ],
      ),
    );
  }
}
