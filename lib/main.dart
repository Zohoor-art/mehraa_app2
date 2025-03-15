import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:mehra_app/modules/chats/chat_screen.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';

import 'package:mehra_app/firebase_options.dart';

import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/modules/rating/add_rating.dart';
import 'package:mehra_app/modules/rating/rating.dart';


import 'package:mehra_app/modules/Story/storyy_view.dart';


import 'package:mehra_app/modules/site/site.dart';
import 'package:mehra_app/modules/SearchLocation/SearchLocation.dart';
import 'package:mehra_app/modules/chats/chat_screen.dart';

import 'package:mehra_app/modules/chats/chats.dart';
import 'package:mehra_app/modules/notifications/Notification.dart';
import 'package:mehra_app/modules/onbording/onboarding_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/modules/reels/home.dart';
import 'package:mehra_app/modules/vervication/vervication.dart';
import 'package:mehra_app/modules/xplore/xplore_screen.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

           child:HomeScreen(),

      )
      );}


}