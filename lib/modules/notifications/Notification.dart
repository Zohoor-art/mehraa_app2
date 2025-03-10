import 'package:flutter/material.dart';
import 'package:mehra_app/modules/notifications/NotificationItem.dart';
import 'package:mehra_app/shared/components/constants.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

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
            width: MediaQuery.of(context).size.width * 0.9, // 90% من عرض الشاشة
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
              color: Colors.white, // لون الخلفية
              borderRadius: BorderRadius.circular(10), // زوايا مدورة
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    
                      horizontal: 8.0,), // تباعد عن الحواف
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0), // تباعد عن الحواف
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
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                NotificationItem(
                  username: 'سارة',
                  action: 'علق على قصتك',
                  time: 'قبل 10 دقائق',
                  avatarUrl: 'assets/images/1.jpg',
                  showButton: true,
                ),
                NotificationItem(
                  username: 'محمد',
                  action: 'بدأ متابعتك',
                  time: 'قبل 15 دقيقة',
                  avatarUrl: 'assets/images/2.jpg',
                  showButton: false,
                ),
                NotificationItem(
                  username: 'ليلى',
                  action: 'أعجب بتعليقك',
                  time: 'قبل 30 دقيقة',
                  avatarUrl: 'assets/images/3.jpg',
                  showButton: true,
                ), NotificationItem(
                  username: 'ليلى',
                  action: 'أعجب بتعليقك',
                  time: 'قبل 30 دقيقة',
                  avatarUrl: 'assets/images/4.jpg',
                  showButton: true,
                ), NotificationItem(
                  username: 'ليلى',
                  action: 'أعجب بتعليقك',
                  time: 'قبل 30 دقيقة',
                  avatarUrl: 'assets/images/5.jpg',
                  showButton: true,
                ),
                NotificationItem(
                  username: 'أحمد',
                  action: 'أعجب بصورة لك',
                  time: 'قبل 5 دقائق',
                  avatarUrl: 'assets/images/4.jpg',
                  showButton: false,
                ),
                 NotificationItem(
                  username: 'ليلى',
                  action: 'أعجب بتعليقك',
                  time: 'قبل 30 دقيقة',
                  avatarUrl: 'assets/images/3.jpg',
                  showButton: true,
                ), NotificationItem(
                  username: 'ليلى',
                  action: 'أعجب بتعليقك',
                  time: 'قبل 30 دقيقة',
                  avatarUrl: 'assets/images/3.jpg',
                  showButton: true,
                ),
                 NotificationItem(
                  username: 'ليلى',
                  action: 'أعجب بتعليقك',
                  time: 'قبل 30 دقيقة',
                  avatarUrl: 'assets/images/3.jpg',
                  showButton: true,
                ), NotificationItem(
                  username: 'ليلى',
                  action: 'أعجب بتعليقك',
                  time: 'قبل 30 دقيقة',
                  avatarUrl: 'assets/images/3.jpg',
                  showButton: true,
                ),
                // يمكنك إضافة المزيد من العناصر هنا
              ],
            ),
          ),
        ],
      ),
    );
  }
}
