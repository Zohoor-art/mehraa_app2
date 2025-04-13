import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/firebase_options.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart'; // تأكد من استيراد HomeScreen

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Tajawal',
      ),
      // تعريف المسارات
      routes: {
        "HomeScreen": (context) => HomeScreen(),
        // يمكنك إضافة مسارات أخرى هنا
        "RegisterScreen": (context) => RegisterScreen(),
      },
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: RegisterScreen(),  // الشاشة التي سيتم عرضها عند بدء التطبيق
      ),
    );
  }
}