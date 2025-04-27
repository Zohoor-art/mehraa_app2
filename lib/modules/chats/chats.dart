import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/chats/call_screen.dart';
import 'package:mehra_app/modules/chats/chat_screen.dart';
import 'package:mehra_app/modules/chats/order_notifcations.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/modules/chats/chat_room.dart';

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
        return 305;
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

  void _showUsersBottomSheet() {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'اختر مستخدم للمراسلة',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where(FieldPath.documentId, isNotEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final userName = user['storeName'] ?? 'Unnamed User';
                        final userId = user.id;
                        final userImage = user['profileImage'] ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: userImage.isNotEmpty
                                ? NetworkImage(userImage)
                                : AssetImage('assets/images/5.jpg') as ImageProvider,
                          ),
                          title: Text(
                            userName,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoom(
                                  userId: userId,
                                  userName: userName,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
            const SizedBox(height: 10),
            headingTitle(),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            Expanded(
              child: IndexedStack(
                index: current,
                children: [
                  // محتوى الدردشات
                  ChatScreen(),
                  // محتوى المكالمات
                  CallScreen(),
                  // محتوى الطلبات
                  OrderNotifications()
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
          onPressed: _showUsersBottomSheet,
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
              EvaIcons.messageSquareOutline,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}