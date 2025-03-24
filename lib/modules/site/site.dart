import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  String? selectedValue; // المتغير لتخزين القيمة المحددة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 3,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(children: [
          Container(
            color: MyColor.lightprimaryColor,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/sites.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 300,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  'طريقة تحديد الموقع',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: Color(0XFF707070),
                  ),
                ),
                SizedBox(height: 40),

                // زر تلقائي
                GradientButton(
                  onPressed: () {},
                  text: 'تلقائي',
                  width: 348,
                  height: 70,
                  fontSize: 40,
                ),

                SizedBox(height: 40),

                // المربع الذي يحتوي على القائمة المنسدلة
                Container(
                  width: 348, // عرض المربع
                  height: 65, // ارتفاع المربع
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple, width: 2), // لون وحجم الإطار
                    borderRadius: BorderRadius.circular(8), // زوايا دائرية للإطار
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (String newValue) {
                      setState(() {
                        selectedValue = newValue; // تعيين القيمة المحددة
                      });
                    },
                    child: Center(
                      child: Text(
                        selectedValue ?? 'يدوي', // عرض القيمة المحددة أو النص الافتراضي
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'مذبح',
                          child: Text('مذبح'),
                        ),
                        PopupMenuItem<String>(
                          value: 'عصر',
                          child: Text('عصر'),
                        ),
                        PopupMenuItem<String>(
                          value: 'شملان',
                          child: Text('شملان'),
                        ),
                      ];
                    },
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}