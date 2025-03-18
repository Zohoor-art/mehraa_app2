import 'package:flutter/material.dart';
import 'create_story_page.dart'; // تأكد من استيراد صفحة إنشاء الاستوري

class StoryPage extends StatelessWidget {
  List<dynamic> story = [
    {"images": 'assets/images/1.jpg', "username": 'زهور الجبرني'},
    {"images": 'assets/images/2.jpg', "username": 'زينب جسار'},
    {"images": 'assets/images/3.jpg', "username": 'علا عبدالله'},
    {"images": 'assets/images/4.jpg', "username": 'ثريا الزليل'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // زر إضافة استوري
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipPath(
                                clipper: HouseClipper(),
                                child: Container(
                                  width: 70,
                                  height: 77,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xff9022B2),
                                        Color(0xffEEAB63),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              ClipPath(
                                clipper: HouseClipper(),
                                child: Container(
                                  width: 60,
                                  height: 67,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Image.asset(
                                    'assets/images/5.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -1,
                                child: GestureDetector(
                                  onTap: () {
                                    // توجيه المستخدم إلى صفحة إنشاء الاستوري
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CreateStoryPage()),
                                    );
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.pink, // استخدم الألوان المناسبة
                                          Colors.purple,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text('حسابي'),
                          ),
                        ],
                      ),
                    ),
                    // توليد قصص أخرى
                    ...List.generate(story.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipPath(
                                  clipper: HouseClipper(),
                                  child: Container(
                                    width: 70,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xff9022B2),
                                          Color(0xffEEAB63),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                ClipPath(
                                  clipper: HouseClipper(),
                                  child: Container(
                                    width: 60,
                                    height: 67,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Image.asset(
                                      '${story[index]["images"]}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text('${story[index]['username']}'),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // زر إضافة استوري أسفل القصص (اختياري)
          ],
        ),
      ),
    );
  }
}

// كلاس القصير لشكل المنزل
class HouseClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width / 2, 0);
    path.lineTo(0, size.height * 0.4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}