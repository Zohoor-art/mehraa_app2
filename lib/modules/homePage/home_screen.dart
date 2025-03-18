import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mehra_app/modules/SearchLocation/SearchLocation.dart';
import 'package:mehra_app/modules/chats/chats.dart';

import 'package:mehra_app/modules/homePage/add_postScreen.dart';

import 'package:mehra_app/modules/homePage/post.dart';
import 'package:mehra_app/modules/homePage/story_page.dart';
import 'package:mehra_app/modules/notifications/Notification.dart';
import 'package:mehra_app/modules/site/site.dart';
import 'package:mehra_app/modules/xplore/xplore_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart'; // تأكد من استيراد صفحة البروفايل
import 'package:mehra_app/shared/components/constants.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Default selected index

  // List of pages corresponding to bottom navigation items
  final List<Widget> _pages = [
    const SiteScreen(),
    const SearchLocation(),
    const HomePage(), // Your Home page
    const XploreScreen(),
    const ChatsPage(),
  ];

  final List<Widget> _navigationItems = [
    const Icon(Icons.location_pin),
    const Icon(Icons.video_collection_sharp),
    const Icon(Icons.home),
    const Icon(Icons.search_sharp),
    const Icon(Icons.comment_rounded),
  ];

  Color bgColor = MyColor.lightprimaryColor;

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
      backgroundColor: MyColor.lightprimaryColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor: MyColor.blueColor,
        backgroundColor: bgColor,
        height: 60,
        index: _currentIndex,
        items: _navigationItems.map((icon) {
          return Icon(
            (icon as Icon).icon, // Cast to Icon to get the icon property
            color: _currentIndex == _navigationItems.indexOf(icon)
                ? Colors.white // Selected color
                : MyColor.blueColor, // Unselected color
          );
        }).toList(),
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update current index
          });
        },
      ),
    );
  }
}

// Separate widget for the home content
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to profile page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen()), // انتقل إلى صفحة البروفايل
                        );
                      },
                      child: CircleAvatar(
                        radius: 15, // Adjust size as needed
                        backgroundImage: AssetImage('assets/images/5.jpg'), 
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Navigate to another page (مثلاً، XploreScreen)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => XploreScreen()),
                        );
                      },
                      child: Icon(FontAwesomeIcons.bars, size: 25),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Navigate to ChatsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Notifications()),
                        );
                      },
                      child: Icon(FontAwesomeIcons.bell, size: 25),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Navigate to another page (مثلاً، الصفحة الخاصة بك)
                        Navigator.push(
                          context,

                          MaterialPageRoute(builder: (context) => AddPostscreen()),

                        );
                      },
                      child: const Icon(Icons.add_circle_outline_outlined, size: 25),
                    ),
                  ],
                ),
                Text(
                  'Mehra',
                  style: GoogleFonts.pacifico(fontSize: 30),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                height: 100, // Adjust height as needed for stories
                child: StoryPage(),
              ),
              Divider(color: Colors.grey[200]),
            ],
          ),
          // Main content area
          Expanded(
            child: Center(
              child: PostWidget(), // Replace with your main content
            ),
          ),
        ],
      ),
    );
  }
}