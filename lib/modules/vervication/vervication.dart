import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/constants.dart';

class VervicationScreen extends StatefulWidget {
  const VervicationScreen({super.key});

  @override
  State<VervicationScreen> createState() => _VervicationScreenState();
}

class _VervicationScreenState extends State<VervicationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<bool> _selectedCircles = List.filled(6, false); // مصفوفة لتتبع حالة الدوائر

  void _onClear() {
    setState(() {
      _controller.clear(); // مسح النص
      _selectedCircles = List.filled(6, false); // إعادة تعيين حالة الدوائر
    });
  }

  void _onCirclePressed(int index) {
    setState(() {
      _selectedCircles[index] = !_selectedCircles[index]; // تغيير حالة الدائرة عند الضغط
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // إخفاء لوحة المفاتيح عند النقر خارج الحقل
        },
        child: Stack(
          children: [
            Container(
              color: MyColor.lightprimaryColor,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/bottom.png',
                fit: BoxFit.cover,
              ),
            ),
            // الكارد العلوي بجوار شريط التطبيق
            Positioned(
              top: 0, // التصاقه بشريط التطبيق
              left: 0,
              right: 0,
              child: Container(
                width: 430, // العرض المطلوب للكارد العلوي
                height: 268, // الارتفاع المطلوب للكارد العلوي
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                       SizedBox(height: 20),
                      CircleAvatar(
                        
                        radius: 40,
                        backgroundImage: AssetImage('assets/1.png'), // صورة الملف الشخصي
                      ),
                      SizedBox(height: 20),
                      Text(
                        'أدخل رمز التحقق',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MyColor.purpleColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      // صف الدوائر
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return GestureDetector(
                            onTap: () => _onCirclePressed(index), // تغيير حالة الدائرة عند الضغط
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              width: 34, // العرض المطلوب للدائرة
                              height: 34, // الارتفاع المطلوب للدائرة
                              decoration: BoxDecoration(
                                gradient: _selectedCircles[index]
                                    ? LinearGradient(
                                        colors: [
                                          Color(0xFF4423B1), // اللون الأول
                                          Color(0xFFA02D87), // اللون الثاني
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null, // لا تدرج إذا لم يتم الضغط
                                color: _selectedCircles[index]
                                    ? null // لا لون أساسي إذا كان هناك تدرج
                                    : Color(0xFFE4E4E4), // اللون الأساسي
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // مركز المحتوى
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 288), // المسافة لتجنب تداخل الكارد العلوي
                  // الكارد السفلي
                  Container(
                    width: 332, // العرض المطلوب للكارد السفلي
                    height: 363, // الارتفاع المطلوب للكارد السفلي
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}