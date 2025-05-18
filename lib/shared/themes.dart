import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: 'Tajawal',
  primarySwatch: Colors.pink,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.pink,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      fontFamily: 'Tajawal',
    ),
    iconTheme: IconThemeData(color: Colors.white),
    elevation: 0,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.pinkAccent,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.pink,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.white,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
  ),
);

ThemeData darkTheme = ThemeData(
  fontFamily: 'Tajawal',

  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  cardColor: Color(0xFF1E1E1E), // لون البلوكات
  primaryColor: Colors.purpleAccent,
  iconTheme: IconThemeData(color: Colors.purpleAccent),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: Colors.purpleAccent),
    elevation: 0,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.purpleAccent,
    foregroundColor: Colors.black,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.purpleAccent,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.black,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.white),
    trackColor: MaterialStateProperty.all(Colors.purpleAccent),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.purpleAccent),
  ),
);
