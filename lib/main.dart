import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


import 'package:mehra_app/firebase_options.dart';
import 'package:mehra_app/modules/Story/storyy_view.dart';
import 'package:mehra_app/modules/rating/rating.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/modules/register/sign_up.dart';
import 'package:mehra_app/modules/signup2/sign_up2.dart';



import 'package:mehra_app/modules/chats/chat_screen.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';

import 'package:mehra_app/firebase_options.dart';
import 'package:mehra_app/modules/chats/all_chats.dart';

import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/modules/rating/add_rating.dart';
import 'package:mehra_app/modules/rating/rating.dart';


import 'package:mehra_app/modules/Story/storyy_view.dart';

import 'package:mehra_app/modules/reels/home.dart';





import 'package:mehra_app/modules/site/site.dart';
import 'package:mehra_app/modules/SearchLocation/SearchLocation.dart';
import 'package:mehra_app/modules/chats/chat_screen.dart';

import 'package:mehra_app/modules/chats/chats.dart';
import 'package:mehra_app/modules/notifications/Notification.dart';
import 'package:mehra_app/modules/onbording/onboarding_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/modules/rating/rating.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/modules/register/sign_up.dart';
import 'package:mehra_app/modules/signup2/sign_up2.dart';
import 'package:mehra_app/modules/settings/Settings.dart';
import 'package:mehra_app/modules/vervication/vervication.dart';
import 'package:mehra_app/modules/xplore/xplore_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('====================User is currently signed out!');
      } else {
        print('=======================User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
  }
}
