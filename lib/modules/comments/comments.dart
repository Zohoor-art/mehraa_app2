import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mehra_app/shared/components/constants.dart';

class Comments extends StatelessWidget {
  const Comments({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> comments = [
      {
        'name': 'روز للورود',
        'time': 'قبل 5 دقائق',
        'image': 'assets/images/1.jpg',
      },
      {
        'name': 'أحمد',
        'time': 'قبل 10 دقائق',
        'image': 'assets/images/2.jpg',
      },
      {
        'name': 'سارة',
        'time': 'قبل 15 دقيقة',
        'image': 'assets/images/3.jpg',
      },
      // يمكنك إضافة المزيد من التعليقات هنا
    ];
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: MyColor.lightprimaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                    padding: const EdgeInsets.only(top: 25, bottom: 20),
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
                  SizedBox(height: 5),
                  Text(
                    'التعليقات',
                    style: TextStyle(fontSize: 20),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // قائمة التعليقات
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              return _buildListItem(
                                comments[index]['name']!,
                                comments[index]['time']!,
                                comments[index]['image']!,
                                context,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: MyColor.lightprimaryColor,
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.8),
                                  spreadRadius: 0,
                                  blurRadius: 9,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage('assets/images/1.jpg'),
                                  radius: 18,
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: ' اكتب تعليق...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.send_outlined,
                                  color: Colors.grey[500],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
      String name, String time, String imageUrl, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(imageUrl),
      ),
      title: Text(name),
      subtitle: Text(time, style: TextStyle(color: Colors.grey[600])),
      trailing: Icon(
        FontAwesomeIcons.heart,
        color: MyColor.blueColor,
        size: 17,
      ),
    );
  }
}
