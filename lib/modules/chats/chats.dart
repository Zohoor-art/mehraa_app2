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
      height: 45,
      child: Column(
        children: [
          Row(
            children: [
              // تبويب الدردشات
              Expanded(
                child: GestureDetector(
                  onTap: () => tabController.animateTo(0),
                  child: Column(
                    children: [
                      Text(
                        tabs[0],
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Tajawal',
                          color: current == 0 ? Colors.black : Colors.grey,
                          fontWeight: current == 0 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                      if (current == 0)
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2, // 40% من نصف الشاشة
                            height: 6,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
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
                ),
              ),
              
              // تبويب الطلبات
              Expanded(
                child: GestureDetector(
                  onTap: () => tabController.animateTo(1),
                  child: Column(
                    children: [
                      Text(
                        tabs[1],
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Tajawal',
                          color: current == 1 ? Colors.black : Colors.grey,
                          fontWeight: current == 1 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                      if (current == 1)
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2, // 40% من نصف الشاشة
                            height: 6,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 55,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            Icon(Icons.search_outlined, size: 30, color: const Color(0xFF6319A5)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'بحث',
                  hintStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Icon(
              Icons.person_outlined,
              color: Color(0xFF6319A5),
              size: 30,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FF),
      appBar: AppBar(
        toolbarHeight: 3,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              headingTitle(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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