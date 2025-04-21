import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:mehra_app/firebase_options.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart'; // تأكد من استيراد HomeScreen

import 'package:flutter_screenutil/flutter_screenutil.dart'; // إضافة مكتبة ScreenUtil
import 'package:mehra_app/firebase_options.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/onbording/onboarding_screen.dart';

import 'package:provider/provider.dart';

import 'models/providers/providers.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // مزودات أخرى إذا لزم الأمر
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // مراقبة حالة تسجيل دخول المستخدم
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('====================User is currently signed out!');
      } else {
        print('=======================User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit( // تهيئة ScreenUtil
      designSize: const Size(375, 812), // حجم التصميم الأساسي
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'تطبيق مهرة',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: 'Tajawal',
          ),
          home: (FirebaseAuth.instance.currentUser != null &&
                  FirebaseAuth.instance.currentUser!.emailVerified)
              ? HomeScreen()
              : OnboardingScreen(),
          // تعيين اتجاه النص للتطبيق بالكامل
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl, // تعيين اتجاه النص إلى اليمين لليسار
              child: child!,
            );
          },
        );
      },

    );
  }
}