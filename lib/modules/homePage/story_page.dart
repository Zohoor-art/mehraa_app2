import 'package:flutter/material.dart';

import 'create_story_page.dart'; // تأكد من استيراد صفحة إنشاء الاستوري

import 'package:mehra_app/shared/components/constants.dart';


class StoryPage extends StatelessWidget {
  List<dynamic> story = [
    {"images": 'assets/images/1.jpg', "username": 'زهور الجبرني'},
    {"images": 'assets/images/2.jpg', "username": 'زينب جسار'},
    {"images": 'assets/images/3.jpg', "username": 'علا عبدالله'},
    {"images": 'assets/images/4.jpg', "username": 'ثريا الزليل'},

    {"images": 'assets/images/1.jpg', "username": 'زهور الجبرني'},
    {"images": 'assets/images/2.jpg', "username": 'زهور الجبرني'},
    {"images": 'assets/images/3.jpg', "username": 'زهور الجبرني'},
    {"images": 'assets/images/4.jpg', "username": 'زهور الجبرني'},

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

                              // Container for the colored border in house shape
                              ClipPath(
                                clipper: HouseClipper(),
                                child: Container(
                                  width: 70, // Width of the outer container (larger)
                                  height: 77, // Height of the outer container (larger)

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

                              // House shape with image inside
                              ClipPath(
                                clipper: HouseClipper(),
                                child: Container(
                                  width: 60, // Width of the inner container
                                  height: 67, // Height of the inner container
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color for the house shape
                                  ),
                                  child: Image.asset(
                                    'assets/images/5.jpg', // صورة البروفايل

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
                        // Container for the colored border in house shape
                                ClipPath(
                                  clipper: HouseClipper(),
                                  child: Container(
                                    width: 70, // Width of the outer container (larger)
                                    height: 76, // Height of the outer container (larger)

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

                                // House shape for stories with image inside
                                ClipPath(
                                  clipper: HouseClipper(),
                                  child: Container(
                                    width: 60, // Width of the inner container
                                    height: 67, // Height of the inner container
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Background color for the house shape

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

            // Additional content can go here
          ],
        ),
      ),
    );
  }
}

// Custom clipper for the house shape

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