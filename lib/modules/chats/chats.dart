import 'package:flutter/material.dart';
import 'package:mehra_app/modules/chats/order_notifcations.dart';
import 'package:mehra_app/modules/chats/recent_chats.dart';
import 'package:mehra_app/shared/components/components.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> with TickerProviderStateMixin {
  late TabController tabController;
  List<String> tabs = ["الدردشات", "الطلبات"];
  int current = 0;
  String _searchQuery = '';

  void onTabChange() {
    setState(() {
      current = tabController.index;
    });
  }

  double changePositionOfLine() {
    switch (current) {
      case 0:
        return MediaQuery.of(context).size.width * 0.5;
      case 1:
        return 0;
      default:
        return 0;
    }
  }

  double changeContainerWidth() {
    return MediaQuery.of(context).size.width * 0.4;
  }

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(onTabChange);
    super.initState();
  }

  @override
  void dispose() {
    tabController.removeListener(onTabChange);
    tabController.dispose();
    super.dispose();
  }

  Widget _buildTabBar() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 35,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((tab) {
              int index = tabs.indexOf(tab);
              return GestureDetector(
                onTap: () {
                  tabController.animateTo(index);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Tajawal',
                      color: current == index ? Colors.black : Colors.grey,
                      fontWeight: current == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AnimatedPositioned(
            bottom: 0,
            left: changePositionOfLine(),
            duration: Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: changeContainerWidth(),
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4423B1),
                    Color(0xFF6B2298),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 55,
      margin: EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search_outlined, size: 30, color: Color(0xFF6319A5)),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
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
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAF5FF),
      appBar: AppBar(
        toolbarHeight: 3,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4423B1),
                Color(0xFF6B2298),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),
              headingTitle(),
              SizedBox(height: 10),
              _buildTabBar(),
              _buildSearchBar(),
              Expanded(
                child: IndexedStack(
                  index: current,
                  children: [
                    RecentChats(searchQuery: _searchQuery),
                    OrderNotifications(searchQuery: _searchQuery),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
