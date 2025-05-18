import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class AnalyticsNotificationScreen extends StatelessWidget {
  final String title;
  final String message;

  const AnalyticsNotificationScreen({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600, // أقصى عرض للبطاقة على الشاشات الكبيرة
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              color: Colors.grey.shade100,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '📊 ملخص الأسبوع',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    Center(
                      child: GradientButton(
                        onPressed: () => Navigator.pop(context),
                        text: 'تم',
                        fontSize: isSmallScreen ? 18 : 20,
                        height: isSmallScreen ? 45 : 50,
                        width: isSmallScreen 
                            ? screenWidth * 0.8 
                            : screenWidth > 600 ? 400 : screenWidth * 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}