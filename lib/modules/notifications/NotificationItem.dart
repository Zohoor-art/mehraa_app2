import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/components.dart';

class NotificationItem extends StatelessWidget {
  final String username;
  final String action;
  final String time;
  final String avatarUrl;
  final bool showButton; // تحدد ما إذا كان يجب عرض الزر

  const NotificationItem({
    Key? key,
    required this.username,
    required this.action,
    required this.time,
    required this.avatarUrl,
    required this.showButton, // إضافة المعامل هنا
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(avatarUrl,
                ),
                radius: 35,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$username $action',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          if (showButton) // عرض الزر فقط إذا كان showButton صحيحًا
            GradientButton(
              onPressed: () {},
              text: 'رد المتابعة',
              width: 101,
              height: 38,
            ),
          if (!showButton) // عرض الصورة إذا كان showButton غير صحيح
            Container(
              width: 85,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // زاوية مدورة
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // زاوية مدورة للصورة
                child: Image.asset(
                  avatarUrl, // استبدل بالصورة المناسبة
                  fit: BoxFit.cover, // لتغطية المساحة بالكامل
                ),
              ),
            ),
        ],
      ),
    );
  }
}
