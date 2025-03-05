import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/constants.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
       Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:NetworkImage(imageUrl), // استخدام imageUrl هنا
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,
                  vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.2),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    padding: EdgeInsets.only(top: 45),
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // الشكل الأول: نسخ الرابط
                                            Column(
                                              children: [
                                                Container(
                                                  height: 52,
                                                  width: 56,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Color(0xFF4423B1),
                                                        Color(0xFFA02D87),
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.link,
                                                    size: 39,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                                Text(
                                                  'نسخ الرابط',
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            // الشكل الثاني: مشاركة
                                            Column(
                                              children: [
                                                Container(
                                                  height: 52,
                                                  width: 56,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Color(0xFF4423B1),
                                                        Color(0xFFA02D87),
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.share,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                                Text(
                                                  'مشاركة',
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            // الشكل الثالث: إبلاغ
                                            Column(
                                              children: [
                                                Container(
                                                  height: 52,
                                                  width: 56,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Colors.red,
                                                        Color.fromARGB(255, 172, 32, 22),
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.report_outlined,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                                Text(
                                                  'إبلاغ',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                                          child: Column(
                                            children: [
                                              // السطر الأول: إلغاء الحساب
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'الغاء المتابعة',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                  ),
                                                  SizedBox(width: 8),
                                                  ShaderMask(
                                                    shaderCallback: (bounds) {
                                                      return LinearGradient(
                                                        colors: [
                                                          Color(0xFF4423B1),
                                                          Color(0xFFA02D87),
                                                        ],
                                                      ).createShader(bounds);
                                                    },
                                                    child: Icon(
                                                      Icons.person_remove,
                                                      color: Colors.white,
                                                      size: 35,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20), // مسافة بين السطور
                                              // السطر الثاني: إخفاء
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'إخفاء',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                  ),
                                                  SizedBox(width: 8),
                                                  ShaderMask(
                                                    shaderCallback: (bounds) {
                                                      return LinearGradient(
                                                        colors: [
                                                          Color(0xFF4423B1),
                                                          Color(0xFFA02D87),
                                                        ],
                                                      ).createShader(bounds);
                                                    },
                                                    child: Icon(
                                                      CupertinoIcons.eye_slash_fill,
                                                      size: 35,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20), // مسافة بين السطور
                                              // السطر الثالث: عن الحساب
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'عن الحساب',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                  ),
                                                  SizedBox(width: 8),
                                                  ShaderMask(
                                                    shaderCallback: (bounds) {
                                                      return LinearGradient(
                                                        colors: [
                                                          Color(0xFF4423B1),
                                                          Color(0xFFA02D87),
                                                        ],
                                                      ).createShader(bounds);
                                                    },
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 35,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Icon(
                              Icons.more_horiz_sharp,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: const Icon(
                          CupertinoIcons.viewfinder,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 30, left: 10, right: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(CupertinoIcons.suit_heart_fill),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 15),
                      decoration: BoxDecoration(
                        color: MyColor.backcardsetting,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'view',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4423B1),
                            Color(0xFFA02D87),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.share),
              ],
            ),
          ), 
          ]
      
      ));
  }
}
