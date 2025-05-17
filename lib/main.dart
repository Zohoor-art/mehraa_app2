import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mehra_app/modules/onbording/onboarding_screen.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/modules/register/email_verification_screen.dart';
import 'package:mehra_app/modules/settings/Settings.dart';
import 'package:mehra_app/modules/settings/UserProvider.dart';
import 'package:mehra_app/modules/settings/language_provider.dart';
import 'package:mehra_app/modules/signup2/sign_up2.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/shared/theme/theme.dart';
import 'package:mehra_app/shared/themes.dart' show lightTheme;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: false,
        builder: (context, child) {
          return MyApp(child: child);
        },
        child: SettingsPage(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget? child;
  const MyApp({Key? key, this.child}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print(intl.Intl.message('المستخدم غير مسجل الدخول!'));
      } else {
        print(intl.Intl.message('المستخدم مسجل الدخول!'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق مهرة',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: languageProvider.selectedLanguage == 'العربية'
          ? const Locale('ar')
          : const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      home: Directionality(
        textDirection: languageProvider.selectedLanguage == 'العربية'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            } else {
              // إذا كان هناك خطأ أو اتصال ضعيف، يتم توجيه المستخدم المسجل إلى الصفحة الرئيسية مباشرة
              return snapshot.data ?? HomeScreen();
            }
          },
        ),
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // الحالة 1: غير مسجل دخول
      if (user == null) {
        return OnboardingScreen();
      }

      // التحقق من أن البريد الإلكتروني قد تم التحقق منه
      if (!user.emailVerified) {
        // محاولة إعادة تحميل بيانات المستخدم مرة واحدة فقط
        try {
          await user.reload();
          final refreshedUser = FirebaseAuth.instance.currentUser;
          if (refreshedUser == null || !refreshedUser.emailVerified) {
            return EmailVerificationScreen(
              userId: user.uid,
              email: user.email ?? '',
              storeName: '',
              profileImage: '',
            );
          }
        } catch (e) {
          // في حالة فشل إعادة التحميل بسبب مشكلة اتصال، يتم تجاهل الخطأ والمتابعة
          print('فشل إعادة تحميل بيانات المستخدم: $e');
        }
      }

      // محاولة جلب بيانات المستخدم من Firestore مع مهلة زمنية
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        final userData = doc.data();

        // الحالة 2: لا يوجد أي بيانات في Firestore → رجوع لـ Register
        if (userData == null) {
          return RegisterScreen();
        }

        // الحالة 3: عنده بيانات لكن التسجيل غير مكتمل → يروح SignUp2screen
        if (userData['isCompleted'] != true) {
          return SignUp2screen(
            userId: user.uid,
            email: userData['email'] ?? user.email ?? '',
            storeName: userData['storeName'] ?? '',
            profileImage: userData['profileImage'] ?? '',
          );
        }
      } catch (e) {
        // في حالة فشل الاتصال بفايرستور، يتم توجيه المستخدم إلى الصفحة الرئيسية
        print('فشل جلب بيانات المستخدم من Firestore: $e');
      }

      // الحالة 4: مكتمل التسجيل أو اتصال ضعيف → يروح للـ HomePage
      return HomeScreen();
    } catch (e) {
      // في حالة أي خطأ غير متوقع، يتم توجيه المستخدم إلى الصفحة الرئيسية
      print('حدث خطأ غير متوقع: $e');
      return HomeScreen();
    }
  }
}