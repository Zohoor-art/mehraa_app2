import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mehra_app/shared/components/constants.dart';

class OrderNotifications extends StatefulWidget {
  const OrderNotifications({super.key});

  @override
  State<OrderNotifications> createState() => _OrderNotificationsState();
}

class _OrderNotificationsState extends State<OrderNotifications> {
  final List<Map<String, dynamic>> _orders = [];
  String _currentUserId = '';
  bool _isLoading = true;
  final Map<String, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => _currentUserId = user.uid);
      await _fetchOrders();
    }
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() => _isLoading = true);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      final orders = await Future.wait(snapshot.docs.map((doc) async {
        final orderData = doc.data();
        final buyerId = orderData['buyerId'] as String;

        final buyerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(buyerId)
            .get();

        final buyerData = buyerDoc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'buyerName':
              buyerData['storeName'] ?? buyerData['displayName'] ?? 'مشتري',
          'productDescription': orderData['productDescription'] ?? 'منتج',
          'productImage': orderData['productImage'],
          'createdAt': orderData['createdAt'],
          'status': orderData['status'] ?? 'pending',
          'buyerImage': buyerData['profileImage'] ?? buyerData['photoURL'],
        };
      }));

      setState(() {
        _orders.clear();
        _orders.addAll(orders);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في جلب الطلبات'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('orders')
          .doc(orderId)
          .update({'status': status});

      // تحديث حالة الطلب محليًا لتجنب إعادة جلب البيانات
      setState(() {
        final index = _orders.indexWhere((order) => order['id'] == orderId);
        if (index != -1) {
          _orders[index]['status'] = status;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              status == 'completed' ? 'تم قبول الطلب بنجاح' : 'تم رفض الطلب'),
          backgroundColor: MyColor.blueColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحديث حالة الطلب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy - hh:mm a').format(dateTime);
  }

  Widget _buildStatusIndicator(String status) {
    final colors = {
      'completed': MyColor.blueColor,
      'cancelled': MyColor.purpleColor,
      'pending': MyColor.pinkColor,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors[status]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[status]!, width: 1),
      ),
      child: Text(
        {
          'completed': 'مكتمل',
          'cancelled': 'ملغي',
          'pending': 'قيد المراجعة'
        }[status]!,
        style: TextStyle(
          color: colors[status],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final isExpanded = _expandedItems[order['id']] ?? false;
    final description = order['productDescription'];
    final shortDescription = description.length > 50
        ? '${description.substring(0, 50)}...'
        : description;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(order['buyerImage'] ?? ''),
              child: order['buyerImage'] == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              order['buyerName'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              _formatDateTime(order['createdAt']),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            trailing: _buildStatusIndicator(order['status']),
          ),
          if (order['productImage'] != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  order['productImage'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 12),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpanded ? description : shortDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                if (description.length > 50) ...[
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedItems[order['id']] = !isExpanded;
                      });
                    },
                    child: Text(
                      isExpanded ? 'عرض أقل' : 'قراءة المزيد',
                      style: TextStyle(
                        color: MyColor.blueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: order['status'] == 'pending'
                      ? () => _updateOrderStatus(order['id'], 'completed')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order['status'] == 'pending'
                        ? MyColor.blueColor
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(
                    order['status'] == 'completed' ? 'تم القبول' : 'قبول الطلب',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: order['status'] == 'pending'
                      ? () => _updateOrderStatus(order['id'], 'cancelled')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        order['status'] == 'pending' ? Colors.red : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(
                      order['status'] == 'cancelled' ? 'تم الرفض' : 'رفض الطلب',
                      style: TextStyle(
                          color: order['status'] == 'pending'
                              ? Colors.white
                              : Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'طلبات المنتجات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: MyColor.pinkColor),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyColor.pinkColor),
              ),
            )
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد طلبات متاحة',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: MyColor.pinkColor,
                  onRefresh: _fetchOrders,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 16, bottom: 24),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderItem(_orders[index]);
                    },
                  ),
                ),
    );
  }
}
