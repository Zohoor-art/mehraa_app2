import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderNotifications extends StatefulWidget {
  const OrderNotifications({super.key});

  @override
  State<OrderNotifications> createState() => _OrderNotificationsState();
}

class _OrderNotificationsState extends State<OrderNotifications> {
  final List<Map<String, dynamic>> orders = []; // قائمة الطلبات
  String currentUserId = ''; // معرف المستخدم الحالي
  String chatUserId =
      ''; // معرف المستخدم في الشات (يمكن تمريره كمعامل إذا لزم الأمر)

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser(); // جلب معرف المستخدم الحالي
  }

  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // تعيين معرف المستخدم الحالي
      });
      _fetchOrders(); // جلب الطلبات بعد تعيين معرف المستخدم
    }
  }

  Future<void> _fetchOrders() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(chatUserId)
          .collection('orders')
          .get();

      print("Fetched orders: ${snapshot.docs.length}"); // طباعة عدد المستندات

      setState(() {
        orders.clear();
        for (var doc in snapshot.docs) {
          print("Order Document: ${doc.data()}"); // طباعة بيانات كل مستند
          orders.add({
            'userName': doc['userName'] ?? 'مستخدم مجهول',
            'productName': doc['productName'] ?? 'منتج غير محدد',
            'timestamp': doc['timestamp'],
            'imageUrl': doc['userImage'] ?? '',
          });
        }
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  String _formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String hour = dateTime.hour > 12
        ? (dateTime.hour - 12).toString() // تحويل إلى صيغة 12 ساعة
        : dateTime.hour.toString();
    String minute =
        dateTime.minute.toString().padLeft(2, '0'); // إضافة صفر إذا لزم الأمر
    String amPm = dateTime.hour >= 12 ? 'PM' : 'AM'; // تحديد AM أو PM

    return '$hour:$minute $amPm'; // تنسيق الوقت
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else {
            return orders.isEmpty
                ? Center(child: Text('لا توجد طلبات متاحة'))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      String formattedTime = _formatTime(order['timestamp']);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(order['imageUrl'] ?? ''),
                              radius: 25,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text(
                                  '${order['userName']} قام بطلب ${order['productName']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Text(
                              formattedTime,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    },
                  );
          }
        },
      ),
    );
  }
}
