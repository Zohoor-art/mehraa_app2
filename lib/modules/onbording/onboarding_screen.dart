import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mehra_app/models/model.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController boardController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    boardController.addListener(() {
      setState(() {
        currentPage = boardController.page?.round() ?? 0;
      });
    });
  }

  void goToNextPage() {
    if (currentPage < boarding.length - 1) {
      boardController.animateToPage(
        currentPage + 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        flexibleSpace: gradientColor(),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: boardController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) => buildOnboardingItem(boarding[index]),
              itemCount: boarding.length,
            ),
          ),
          SizedBox(height: 20, child: smooth_page_indicator()),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientButton(
                fontSize: 18,
                height: 46,
                width: 171,
                onPressed: goToNextPage,
                text: 'التالي',
              ),
              const SizedBox(width: 20),
              GradientButton(
                fontSize: 18,
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
          const SizedBox(height: 25),
          bottomImage()
        ],
      ),
    );
  }

  Widget smooth_page_indicator() => Center(
    child: SmoothPageIndicator(
      controller: boardController,
      effect: const ExpandingDotsEffect(
        dotColor: Color(0xFFC4BCBC),
        activeDotColor: Color(0xFF4423B1),
        dotHeight: 10,
        dotWidth: 10,
        expansionFactor: 2,
        paintStyle: PaintingStyle.fill,
        spacing: 5.0,
      ),
      count: boarding.length,
      onDotClicked: (index) {
        boardController.animateToPage(
          index,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    ),
  );
}