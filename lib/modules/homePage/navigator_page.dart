// navigator_page.dart
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/SearchLocation/SearchLocation.dart';
import 'package:mehra_app/modules/chats/chats.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/site/site.dart';
import 'package:mehra_app/modules/xplore/xplore_screen.dart';
import 'package:mehra_app/shared/components/constants.dart';

class NavigatorPage extends StatefulWidget {
  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  int _currentIndex = 2; // Default selected index

  // List of pages corresponding to bottom navigation items
  final List<Widget> _pages = [
    const SiteScreen(),
    const SearchLocation(),
    const HomeScreen(), // Your Home page
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