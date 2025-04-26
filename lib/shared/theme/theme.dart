import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.pink,
  scaffoldBackgroundColor: Color(0xFF121216),
  appBarTheme: AppBarTheme(
    titleSpacing: 20,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Color(0xFF6319A5),
      statusBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.pinkAccent,
  ),
  fontFamily: 'Tajawal',
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.pinkAccent,
    unselectedItemColor: Colors.grey,
    elevation: 20,
    backgroundColor: Color(0xFF22232A),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
  ),
);
// ThemeData lightTheme = ThemeData(
//   primarySwatch: Colors.pink,
//   scaffoldBackgroundColor: MyColor.darkprimaryColor,
//   appBarTheme: AppBarTheme(
//     systemOverlayStyle: SystemUiOverlayStyle(
//       statusBarColor: HexColor('333739'),
//       statusBarIconBrightness: Brightness.light,
//     ),
//     titleTextStyle: const TextStyle(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 20,
//     ),
//     backgroundColor: HexColor('333739'),
//     elevation: 0,
//     iconTheme: const IconThemeData(
//       color: Colors.white,
//     ),
//   ),
//   floatingActionButtonTheme: const FloatingActionButtonThemeData(
//     backgroundColor: Colors.pinkAccent,
//   ),
//   bottomNavigationBarTheme: BottomNavigationBarThemeData(
//     type: BottomNavigationBarType.fixed,
//     selectedItemColor: Colors.pinkAccent,
//     unselectedItemColor: Colors.grey,
//     elevation: 20,
//     backgroundColor: HexColor('333739'),
//   ),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(
//       fontSize: 18,
//       fontWeight: FontWeight.w600,
//       color: Colors.white,
//     ),
//   ),
// );
// import 'package:google_fonts/google_fonts.dart';

class MyTheme {
  static Color kUnreadChatBG = Color(0xFFA02D87);

  // static final TextStyle kAppTitle = GoogleFonts.grandHotel(fontSize: 36);

  static final TextStyle heading2 = TextStyle(
      color: Color(0xff514D4D),
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
      fontFamily: 'Tajawal');

  static final TextStyle chatSenderName = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  static final TextStyle bodyText1 = TextStyle(
      color: Color(0xffAEABC9),
      fontSize: 14,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w500);

  static final TextStyle bodyTextMessage = TextStyle(
      fontSize: 13,
      letterSpacing: 1.5,
      fontFamily: 'Tajawal',
      fontWeight: FontWeight.w600);

  static final TextStyle bodyTextTime = TextStyle(
    color: Color(0xffAEABC9),
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );
}