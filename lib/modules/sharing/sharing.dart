import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class Sharing extends StatelessWidget {
  const Sharing({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/3.jpg',
      'assets/images/4.jpg',
      'assets/images/5.jpg',
      'assets/images/4.jfif',
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/3.jpg',
      'assets/images/4.jpg',
      'assets/images/5.jpg',
      'assets/images/4.jfif',
    ];

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: MyColor.lightprimaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      width: 79,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D6D6),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.transparent,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(images[0]),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                const SizedBox(width: 5),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'اكتب رسالة...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.search_outlined,
                              size: 30, color: Color(0xFF6319A5)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'بحث',
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Tajawal',
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.person_outlined,
                            color: Color(0xFF6319A5),
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    AssetImage('assets/images/1.jpg'),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                'اضافة الى القصة',
                                style: TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          // قائمة الصور
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return _buildListItem('روز للورود الطبيعية',
                                  images[index], context);
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String name, String imageUrl, BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(6),
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(imageUrl),
      ),
      title: Text(name),
      trailing: GradientButton(
          onPressed: () {}, text: 'إرسال', height: 38, width: 101),
    );
  }
}
