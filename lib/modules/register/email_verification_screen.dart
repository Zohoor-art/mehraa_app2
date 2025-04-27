import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/models/firebase/auth_methods.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/signup2/sign_up2.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String storeName;
  final String profileImage;

  const EmailVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.storeName,
    required this.profileImage,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isVerified = false;
  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid == widget.userId) {
      await user.reload();
      if (user.emailVerified) {
        setState(() {
          isVerified = true;
        });
        // انتقل مباشرة إلى الصفحة الثانية للتسجيل
        _navigateToSecondSignUp();
      }
    }
  }

  Future<void> _resendVerification() async {
    setState(() => isResending = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == widget.userId) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إعادة إرسال رابط التحقق إلى ${widget.email}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إعادة الإرسال: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isResending = false);
    }
  }

  void _navigateToSecondSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignUp2screen(
          userId: widget.userId,
          email: widget.email,
          storeName: widget.storeName,
          profileImage: widget.profileImage,
        ),
      ),
    );
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
      body: Stack(
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
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: MyColor.purpleColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'التحقق من البريد الإلكتروني',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MyColor.blueColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'تم إرسال رابط التحقق إلى بريدك الإلكتروني:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MyColor.purpleColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'الرجاء التحقق من بريدك الإلكتروني ثم اضغط على الزر أدناه للمتابعة',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 30),
                  if (isLoading)
                    CircularProgressIndicator()
                  else
                    GradientButton(
                      onPressed: () async {
                        setState(() => isLoading = true);
                        bool verified = await AuthMethods()
                            .checkEmailVerification(widget.userId);
                        setState(() => isLoading = false);

                        if (verified) {
                          _navigateToSecondSignUp();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('لم يتم التحقق بعد، الرجاء التحقق من بريدك الإلكتروني'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      text: 'تم التحقق والمتابعة',
                      width: isSmallScreen ? screenWidth * 0.8 : 319,
                      height: isSmallScreen ? 50 : 67,
                    ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: isResending ? null : _resendVerification,
                    child: Text(
                      isResending ? 'جاري الإرسال...' : 'إعادة إرسال رابط التحقق',
                      style: TextStyle(
                        color: MyColor.blueColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}