import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mehra_app/models/model.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/shared/components/components.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    boardController.addListener(() {
      if (boardController.page!.round() == boarding.length - 1) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // تغيير لون شريط الحالة
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4423B1),
                Color(0xFF6B2298),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: boardController,
              itemBuilder: (context, index) =>
                  buildOnboardingItem(boarding[index]),
              itemCount: boarding.length,
            ),
          ),
          SizedBox(height: 20, child: smooth_page_indicator()),

          const SizedBox(height: 10), // امسافة بين العناصر
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientButton(
                height: 46,
                width: 171,
                onPressed: () {
                 
                  
                },
                text: 'التالي',
              ),
              const SizedBox(width: 20), // المسافة بين الزرين
              GradientButton(
                height: 46,
                width: 171,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                text: 'تخطي',
              ),
            ],
          ),
          const SizedBox(height: 25), // المسافة بين الأزرار والدوائر
          bottomImage()
        ],
      ),
    );
  }
}
