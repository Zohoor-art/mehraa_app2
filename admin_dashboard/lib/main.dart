import 'dart:async';
import 'dart:ui';
import 'package:admin_dashboard/dashBoard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <-- تأكد أن الملف موجود

// ✅ ScrollBehavior مخصص لدعم الماوس على الويب
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // مهم جدًا للتمرير في الويب
      };
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(AdminDashboardApp());
  }, (error, stack) {
    print('خطأ غير متوقع: $error');
  });
}

class AdminDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لوحة تحكم المشرف',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      scrollBehavior: MyCustomScrollBehavior(), // ✅ هذا السطر مضاف
      home: DashboardScreen(),
    );
  }
}
