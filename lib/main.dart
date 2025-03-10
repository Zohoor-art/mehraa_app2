import 'package:flutter/material.dart';

import 'package:mehra_app/modules/Story/storyy_view.dart';
import 'package:mehra_app/modules/reels/home.dart';
import 'package:mehra_app/modules/reels/options_screen.dart';
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
import 'package:mehra_app/modules/tabs/reels_view.dart';
import 'package:mehra_app/modules/vervication/vervication.dart';
import 'package:mehra_app/modules/xplore/xplore_screen.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:story_view/story_view.dart';


void main() {
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
        child: HomePage() 
      ),

    );
  }
}