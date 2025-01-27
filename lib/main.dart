import 'package:flutter/material.dart';
import 'package:mehra_app/modules/chats/chat_screen.dart';
import 'package:mehra_app/modules/chats/chats.dart';
import 'package:mehra_app/modules/notifications/Notification.dart';
import 'package:mehra_app/modules/onbording/onboarding_screen.dart';
import 'package:mehra_app/modules/rating/rating.dart';

import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/modules/register/sign_up.dart';
import 'package:mehra_app/modules/signup2/sign_up2.dart';
import 'package:mehra_app/modules/settings/Settings.dart';
import 'package:mehra_app/modules/vervication/vervication.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Tajawal'),
      home: Directionality(

          textDirection: TextDirection.rtl,
           child: VervicationScreen()),

    );
  }
}
