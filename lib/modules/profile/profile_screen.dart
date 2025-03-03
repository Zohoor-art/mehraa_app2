import 'package:flutter/material.dart';
import 'package:mehra_app/models/user_model.dart';
import 'package:mehra_app/modules/chats/chat_room.dart';
import 'package:mehra_app/modules/rating/rating.dart';
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

  final List<Widget> tabBarViews = [
    FeedView(),
    ReelsView(),
    TaggedView(),
  ];

  bool _isExpanded = false;  // To control overall expansion

  // Define shop's opening hours
  final TimeOfDay openingTime = TimeOfDay(hour: 9, minute: 0);  // 9:00 AM
  final TimeOfDay closingTime = TimeOfDay(hour: 21, minute: 0); // 9:00 PM

  bool isOpen() {
    final now = TimeOfDay.now();
    // Check if current time is within opening hours
    return (now.hour > openingTime.hour || (now.hour == openingTime.hour && now.minute >= openingTime.minute)) &&
           (now.hour < closingTime.hour || (now.hour == closingTime.hour && now.minute < closingTime.minute));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
      appBar: AppBar(
  toolbarHeight: 38,
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
  actions: [
    IconButton(
      icon: Icon(Icons.edit, color: Colors.white),
      onPressed: () {
        // Handle edit action
      },
    ),
    IconButton(
      icon: Icon(Icons.share, color: Colors.white),
      onPressed: () {
        // Handle share
        // action
      },
    ),
    Padding(
      padding: const EdgeInsets.only(right: 265.0),
      child: IconButton(
        icon: Icon(Icons.message, color: Colors.white),
        onPressed: () {
          // Handle message action
          Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatRoom(user: User(id: 1, name: 'Adison', avatar: 'assets/images/2.jpg'),)), // Navigate to ChatPage
    );
        },
      ),
    ),
  ],
),
        
        body: ListView(
          
          children: [
            SizedBox(height: 20.0,),
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
                      fit: BoxFit.cover,
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
            // Opening Hours and Status
            Container(
              alignment: Alignment.center,
              // Opening Hours and Status

  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ساعات العمل: 9:00 ص - 9:00 م',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      SizedBox(height: 5.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isOpen() ? 'المتجر مفتوح' : 'المتجر مغلق',
            style: TextStyle(
              color: isOpen() ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  ),

            ),
            SizedBox(height: 5.0),
            // Overall Details with Read More feature
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    'متجر زهره المتجر الذي سيجعل هاتفك انعكاسا لك وهداياك تصنع بحب.\n'
                    '\n'
                    'https://github.com/Zohoor-art/mehraa_app2/branches\n'
                    'https://github.com/Zohoor-art/mehraa_app2/branches',
                    maxLines: _isExpanded ? null : 2,
                    textAlign: TextAlign.center,
                    overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 5.0),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded; // Toggle the expansion state
                      });
                    },
                    child: Text(_isExpanded ? 'عرض أقل' : 'عرض المزيد', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            // Rating and Buttons
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('التقييم', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 5),
                      ...List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        );
                      }),
                    ],
                  ),
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
                        onPressed: () {
                          Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RatingCard()), // Navigate to ChatPage
    );
                        },
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