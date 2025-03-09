import 'package:flutter/material.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/modules/rating/add_rating.dart';
import 'package:mehra_app/modules/rating/rating.dart';
import 'package:mehra_app/modules/site/site.dart';
import 'package:mehra_app/modules/SearchLocation/SearchLocation.dart';

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
        child: RatingsListPage(), 
      ),
    );
  }
}