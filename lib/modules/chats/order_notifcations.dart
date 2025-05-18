import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mehra_app/shared/components/constants.dart';

class OrderNotifications extends StatefulWidget {
  final String searchQuery;
  
  const OrderNotifications({super.key, required this.searchQuery});

  @override
  State<OrderNotifications> createState() => _OrderNotificationsState();
}

class _OrderNotificationsState extends State<OrderNotifications> {
  final List<Map<String, dynamic>> _orders = [];
  String _currentUserId = '';
  bool _isLoading = true;
  final Map<String, bool> _expandedItems = {};
  int _weeklyOrders = 0;
  int _monthlyOrders = 0;
  int _yearlyOrders = 0;

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
      await _fetchOrdersCount();
    }
  }

  Future<void> _fetchOrdersCount() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);

      final weeklyQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('orders')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(startOfWeek));

      final monthlyQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('orders')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(startOfMonth));

      final yearlyQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('orders')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(startOfYear));

      final weeklySnapshot = await weeklyQuery.get();
      final monthlySnapshot = await monthlyQuery.get();
      final yearlySnapshot = await yearlyQuery.get();

      setState(() {
        _weeklyOrders = weeklySnapshot.size;
        _monthlyOrders = monthlySnapshot.size;
        _yearlyOrders = yearlySnapshot.size;
      });
    } catch (e) {
      print('Error fetching orders count: $e');
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

  Widget _buildOrdersStatsCard(String title, int count, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 2),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersStats() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 8 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات الطلبات',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Row(
            children: [
              _buildOrdersStatsCard('هذا الأسبوع', _weeklyOrders, MyColor.blueColor),
              _buildOrdersStatsCard('هذا الشهر', _monthlyOrders, MyColor.pinkColor),
              _buildOrdersStatsCard('هذه السنة', _yearlyOrders, MyColor.purpleColor),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('orders')
          .doc(orderId)
          .update({'status': status});

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

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
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
          fontSize: isSmallScreen ? 10 : 12,
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: isSmallScreen ? 8 : 16,
      ),
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
              radius: isSmallScreen ? 20 : 24,
              backgroundImage: NetworkImage(order['buyerImage'] ?? ''),
              child: order['buyerImage'] == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              order['buyerName'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            subtitle: Text(
              _formatDateTime(order['createdAt']),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isSmallScreen ? 10 : 12,
              ),
            ),
            trailing: _buildStatusIndicator(order['status']),
          ),
          if (order['productImage'] != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 16,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  order['productImage'],
                  height: isSmallScreen ? 120 : 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: isSmallScreen ? 120 : 180,
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
            SizedBox(height: isSmallScreen ? 8 : 12),
          ],
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpanded ? description : shortDescription,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[800],
                  ),
                ),
                if (description.length > 50) ...[
                  SizedBox(height: isSmallScreen ? 4 : 8),
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
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 20,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                    ),
                    child: Text(
                      order['status'] == 'completed' ? 'تم القبول' : 'قبول الطلب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: order['status'] == 'pending'
                        ? () => _updateOrderStatus(order['id'], 'cancelled')
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          order['status'] == 'pending' ? Colors.red : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 20,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                    ),
                    child: Text(
                      order['status'] == 'cancelled' ? 'تم الرفض' : 'رفض الطلب',
                      style: TextStyle(
                        color: order['status'] == 'pending'
                            ? Colors.white
                            : Colors.grey,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterOrders() {
    if (widget.searchQuery.isEmpty) return _orders;
    
    return _orders.where((order) {
      return order['buyerName'].toString().toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
             order['productDescription'].toString().toLowerCase().contains(widget.searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filterOrders();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'طلبات المنتجات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: MyColor.pinkColor),
            onPressed: () {
              _fetchOrders();
              _fetchOrdersCount();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyColor.pinkColor),
              ),
            )
          : filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: isSmallScreen ? 50 : 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        widget.searchQuery.isEmpty 
                            ? 'لا توجد طلبات متاحة'
                            : 'لا توجد نتائج بحث',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: MyColor.pinkColor,
                  onRefresh: () async {
                    await _fetchOrders();
                    await _fetchOrdersCount();
                  },
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: isSmallScreen ? 8 : 16,
                      bottom: isSmallScreen ? 16 : 24,
                    ),
                    children: [
                      _buildOrdersStats(),
                      ...filteredOrders.map((order) => _buildOrderItem(order)).toList(),
                    ],
                  ),
                ),
    );
  }
}