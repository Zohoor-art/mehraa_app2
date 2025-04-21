import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mehra_app/modules/notifications/NotificationItem.dart';
import 'package:mehra_app/shared/components/constants.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref('notifications');
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationsRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) { // استخدام exists للتحقق إذا كان هناك قيمة
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        // تجميع الإشعارات
        List<NotificationItem> loadedNotifications = [];
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            loadedNotifications.add(NotificationItem(
              username: value['username'] ?? 'Unknown',
              action: value['action'] ?? 'No Action',
              time: value['time'] ?? 'Unknown Time',
              avatarUrl: value['avatarUrl'] ?? 'assets/images/default_avatar.png',
              showButton: value['showButton'] ?? false,
            ));
          }
        });
        setState(() {
          notifications = loadedNotifications;
        });
      } else {
        // في حالة عدم وجود بيانات
        setState(() {
          notifications = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FF),
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
      body: Column(
        children: [
          SizedBox(height: 10), // مسافة فوق الكارد الجديد
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 55,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 0),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: MyColor.blueColor),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'الاشعارات',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 12, 12, 12),
                      fontSize: 25,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Icon(
                    Icons.notifications,
                    size: 22,
                    color: MyColor.blueColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return notifications[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}