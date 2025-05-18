import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mehra_app/modules/register/sign_up.dart';
import 'package:mehra_app/modules/signup2/sign_up2.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // تم إلغاء العملية

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تسجيل الدخول: $e')),
      );
    }
  }

  void navigateToCommercialSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpscreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ترقية الحساب"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "اختر نوع الترقية التي ترغب بها:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            UpgradeOption(
              title: "تسجيل دخول بحساب Google",
              description: "احصل على صلاحيات التفاعل مع المتاجر مثل المتابعة والتعليق.",
              onPressed: () => signInWithGoogle(context),
            ),

            const SizedBox(height: 16),

            UpgradeOption(
              title: "ترقية لحساب تجاري",
              description: "أنشئ منشوراتك الخاصة وابدأ في عرض منتجاتك.",
              onPressed: () => navigateToCommercialSignUp(context),
            ),
          ],
        ),
      ),
    );
  }
}

class UpgradeOption extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;

  const UpgradeOption({
    super.key,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text("الترقية الآن"),
            ),
          ],
        ),
      ),
    );
  }
}
