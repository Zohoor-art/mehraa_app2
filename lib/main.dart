import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:mehra_app/modules/chats/chat_screen.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';

import 'package:mehra_app/firebase_options.dart';
import 'package:mehra_app/modules/Story/storyy_view.dart';
<<<<<<<<< Temporary merge branch 1

import 'package:mehra_app/modules/site/site.dart';
import 'package:mehra_app/modules/SearchLocation/SearchLocation.dart';
import 'package:mehra_app/modules/chats/chat_screen.dart';
=========
>>>>>>>>> Temporary merge branch 2
import 'package:mehra_app/modules/chats/chats.dart';
import 'package:mehra_app/modules/notifications/Notification.dart';
import 'package:mehra_app/modules/onbording/onboarding_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/modules/reels/home.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Tajawal',
      ),
      home: Directionality(

        textDirection: TextDirection.rtl,
<<<<<<<<< Temporary merge branch 1

        child: StoryyView(title: '',) 

=========
        child: Notifications() 
>>>>>>>>> Temporary merge branch 2
      ),

    );
  }
}
