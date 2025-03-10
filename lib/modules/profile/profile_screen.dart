import 'package:flutter/material.dart';
import 'package:mehra_app/modules/tabs/feed_view.dart';
import 'package:mehra_app/modules/tabs/reels_view.dart';
import 'package:mehra_app/modules/tabs/tagged_view.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Widget> tabs = [
    Tab(icon: Icon(Icons.image)),
    Tab(icon: Icon(Icons.video_collection)),
    Tab(icon: Icon(Icons.person_2_sharp)),
  ];

  // Tap bar view pages
  final List<Widget> tabBarViews = [
    FeedView(),
    ReelsView(),
    TaggedView(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
         appBar: AppBar(
        toolbarHeight: 50,
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
         title: Text('Profile',
         style: TextStyle(color: Colors.white),),
          actions: [
            IconButton(
              icon: Icon(Icons.edit,
              color: Colors.white,),
              onPressed: () {
                // Handle edit action
              },
            ),
            IconButton(
              icon: Icon(Icons.share,color: Colors.white,),
              onPressed: () {
                // Handle share action
              },
            ),
          ]
      ),
       
        body: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Following
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '444',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'متابع',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
                SizedBox(width: 20.0),
                // Profile Picture
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ClipOval(
                    child: Image.asset('assets/images/4.jfif', // Replace with your image URL
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover, // Ensures the image covers the circle
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                // Followers
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '444k',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'متابعين',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.0),
            // Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'متجر زهره',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(' | '),
                Text(
                  'صانعة الجمال',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            // Bio
            Container(
              alignment: Alignment.center,
              child: Text(
                'متجر زهره المتجر الذي سيجعل هاتفك انعكاسا لك وهداياك تصنع بحب',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 10.0),
            // Links
            Column(
              children: [
                Text(
                  'https://github.com/Zohoor-art/mehraa_app2/branches',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                Text(
                  'https://github.com/Zohoor-art/mehraa_app2/branches',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            // Rating and Buttons
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stars and Rating Text
                  Row(
                    children: [
                      Text('التقييم', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 5),
                      ...List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border, // 4 stars filled
                          color: Colors.amber,
                        );
                      }),
                    ],
                  ),
                  // Buttons
                  Row(
                    children: [
                      GradientButton(
                        onPressed: () {},
                        text: 'تفاصيل',
                        width: 70,
                        height: 35,
                        fontSize: 10,
                      ),
                      SizedBox(width: 10),
                      GradientButton(
                        onPressed: () {},
                        text: 'تقييم',
                        width: 70,
                        height: 35,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            TabBar(tabs: tabs),
            SizedBox(
              height: 1000,
              child: TabBarView(children: tabBarViews),
            ),
          ],
        ),
      ),
    );
  }
}