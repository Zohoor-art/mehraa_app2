import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/chats/chat_screen.dart';
import 'package:mehra_app/shared/components/components.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> with TickerProviderStateMixin {
  late TabController tabController;
  List<String> tabs = [
    "الدردشات",
    "المكالمات",
    "الطلبات",
  ];

  int current = 0;
  void onTabChange() {
    setState(() {
      current = tabController.index;
      print(current);
    });
  }

  double changePosisinedofLine() {
    switch (current) {
      case 0:
        return 310;
      case 1:
        return 150;
      case 2:
        return 0;
      default:
        return 0;
    }
  }

  double changeContainer() {
    return 80; // تعديل هنا ليكون ثابتًا
  }

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      onTabChange();
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.addListener(() {
      onTabChange();
    });
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
        child: Column(
          children: [
            const SizedBox(height: 20),
          headingTitle(),
           const SizedBox(height: 20),
            SizedBox(
              width: size.width,
              height: size.height * 0.05,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 10,
                    right: 10,
                    child: SizedBox(
                      width: size.width,
                      height: size.height * 0.04,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                current = index;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: index == 7 ? 40 : 70,
                                top: 10,
                                right: 10,
                              ),
                              child: Text(
                                tabs[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Tajawal',
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    bottom: 0,
                    left: changePosisinedofLine(),
                    curve: Curves.fastLinearToSlowEaseIn,
                    duration: const Duration(milliseconds: 500),
                    child: AnimatedContainer(
                      curve: Curves.fastLinearToSlowEaseIn,
                      margin: const EdgeInsets.only(left: 10),
                      duration: const Duration(milliseconds: 500),
                      width: changeContainer(),
                      height: size.height * 0.008,
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
            const SizedBox(height: 20),
            Container(
              width: size.width * 0.9,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
                    Icon(Icons.search_outlined, size: 30, color: Color(0xFF6319A5)),
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
            const SizedBox(height: 20),
            Expanded(
              child: IndexedStack(
                index: current,
                children: [
                  // محتوى الدردشات
                  ChatScreen(),
                  // محتوى المكالمات
                  const Center(
                    child: Text(
                      'محتوى المكالمات',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  // محتوى الطلبات
                  const Center(
                    child: Text(
                      'محتوى الطلبات',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
            right: 320, bottom: 20), // تحريك الزر إلى اليسار
        child: FloatingActionButton(
          onPressed: () {},
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6319A5), // اللون الأول
                  Color(0xFFA02D87), // اللون الثاني
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              current== 0
                  ? EvaIcons.messageSquareOutline
                  : current == 1
                      ? EvaIcons.phoneCallOutline
                      : EvaIcons.shoppingCartOutline,
              color: Colors.white,
            ),
          ),
        ),
      ),
    
    );
  }
}
