import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mehra_app/shared/components/constants.dart';

class OptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 200),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/images/3.jpg'),
                        radius: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'روز للورود الطبيعية',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.verified, size: 15,
                      color: MyColor.purpleColor,),
                      SizedBox(width: 6),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black
                              .withOpacity(0.5), // خلفية بيضاء شفافة
                          // color: Colors.white, // لون النص
                        ),
                        child: Text(
                          'متابعة',
                          style: TextStyle(
                            color: Colors.white, // لون النص
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Text(
                    'اهلا اهلا يا رمضان 💙❤💛 ..',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_sharp,
                        color: MyColor.blueColor,
                        size: 16,
                      ),
                      Text(
                        'صنعاء',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.music_note,
                        color: MyColor.blueColor,
                        size: 16,
                      ),
                      Text(
                        'الصوت الأصلي- اغنية مسلسل الحفرة',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            MyColor.blueColor,
                            MyColor.purpleColor,
                            MyColor.pinkColor,
                          ],
                        ).createShader(bounds);
                      },
                      child: FaIcon(
                        FontAwesomeIcons.gift, // أيقونة الهدايا من Font Awesome
                        size: 33.0, // حجم الأيقونة
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '601k',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            MyColor.blueColor,
                            MyColor.purpleColor,
                            MyColor.pinkColor,
                          ],
                        ).createShader(bounds);
                      },
                      child: FaIcon(
                        FontAwesomeIcons
                            .heart, // أيقونة الهدايا من Font Awesome
                        size: 33.0, // حجم الأيقونة
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '601k',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            MyColor.blueColor,
                            MyColor.purpleColor,
                            MyColor.pinkColor,
                          ],
                        ).createShader(bounds);
                      },
                      child: Icon(
                        Icons
                            .mode_comment_outlined, // أيقونة الهدايا من Font Awesome
                        size: 33.0, // حجم الأيقونة
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '1123',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Transform(
                      transform: Matrix4.rotationZ(6.5),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              MyColor.blueColor,
                              MyColor.purpleColor,
                              MyColor.pinkColor,
                            ],
                          ).createShader(bounds);
                        },
                        child: Icon(
                          Icons.send, // أيقونة الهدايا من Font Awesome
                          size: 33.0, // حجم الأيقونة
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Icon(
                      Icons.more_vert,
                      color: Colors.black,
                    ),
                    SizedBox(height: 20),
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/5.jpg'),
                      radius: 16,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
