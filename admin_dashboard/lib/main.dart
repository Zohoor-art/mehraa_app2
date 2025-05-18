import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart'; // <-- تأكد أن الملف موجود

// ✅ ScrollBehavior مخصص لدعم الماوس على الويب
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // مهم جدًا للتمرير في الويب
      };
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(AdminDashboardApp());
  }, (error, stack) {
    print('خطأ غير متوقع: $error');
  });
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Stream<int> _getCollectionCount(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المشرف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              children: [
                DashboardCard(
                  title: 'المستخدمين',
                  icon: Icons.person,
                  stream: _getCollectionCount('users'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersDetailsPage())),
                ),
                DashboardCard(
                  title: 'المنشورات',
                  icon: Icons.post_add,
                  stream: _getCollectionCount('posts'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPostsPage())),
                ),
                DashboardCard(
                  title: 'الطلبات',
                  icon: Icons.shopping_cart,
                  stream: _getCollectionCount('orders'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen())),
                ),
                DashboardCard(
                  title: 'التقييمات',
                  icon: Icons.star,
                  stream: _getCollectionCount('storeRatings'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatedStoresPage())),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'أحدث المنشورات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).limit(5).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: post['postUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post['postUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image, size: 40),
                        title: Text(post['description'] ?? 'بدون وصف'),
                        subtitle: Text('ID: ${post.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final Color darkPurple = const Color(0xFF5B2C6F);
  final Color lightPurple = const Color(0xFFD7BDE2);

  DateTime get startOfWeek => DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6));
  DateTime get startOfLastWeek => startOfWeek.subtract(const Duration(days: 7));
  DateTime get endOfLastWeek => startOfWeek.subtract(const Duration(days: 1));

  Future<Map<String, dynamic>> getWeeklyAnalytics() async {
    final ratingsSnapshot = await FirebaseFirestore.instance.collection('storeRatings')
      .where('timestamp', isGreaterThanOrEqualTo: startOfWeek)
      .get();

    final lastWeekRatingsSnapshot = await FirebaseFirestore.instance.collection('storeRatings')
      .where('timestamp', isGreaterThanOrEqualTo: startOfLastWeek)
      .where('timestamp', isLessThanOrEqualTo: endOfLastWeek)
      .get();

    int totalRatings = ratingsSnapshot.docs.length;
    int lastWeekTotalRatings = lastWeekRatingsSnapshot.docs.length;

    double commitmentTotal = 0, interactionTotal = 0, qualityTotal = 0;

    for (final doc in ratingsSnapshot.docs) {
      final data = doc.data();
      commitmentTotal += data['commitment'] ?? 0;
      interactionTotal += data['interactionStyle'] ?? 0;
      qualityTotal += data['productQuality'] ?? 0;
    }

    String highestCategory = 'الالتزام';
    String lowestCategory = 'الأسلوب';
    double highestValue = commitmentTotal;
    double lowestValue = interactionTotal;

    if (interactionTotal > highestValue) {
      highestCategory = 'الأسلوب';
      highestValue = interactionTotal;
    }
    if (qualityTotal > highestValue) {
      highestCategory = 'جودة المنتج';
      highestValue = qualityTotal;
    }
    if (commitmentTotal < lowestValue) {
      lowestCategory = 'الالتزام';
      lowestValue = commitmentTotal;
    }
    if (qualityTotal < lowestValue) {
      lowestCategory = 'جودة المنتج';
      lowestValue = qualityTotal;
    }

    return {
      'totalRatings': totalRatings,
      'lastWeekRatings': lastWeekTotalRatings,
      'highestCategory': highestCategory,
      'lowestCategory': lowestCategory
    };
  }

  Future<Map<String, dynamic>?> getMostOrderedProduct() async {
    final ordersSnapshot = await FirebaseFirestore.instance
      .collectionGroup('orders')
      .where('createdAt', isGreaterThanOrEqualTo: startOfWeek)
      .get();

    final orderCount = <String, int>{};
    final productDetails = <String, Map<String, dynamic>>{};

    for (final doc in ordersSnapshot.docs) {
      final postId = doc['postId'];
      orderCount[postId] = (orderCount[postId] ?? 0) + 1;
      productDetails[postId] = doc.data();
    }

    if (orderCount.isEmpty) return null;

    final topProductId = orderCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return productDetails[topProductId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        title: const Text('تحليلات الأسبوع', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder(
        future: Future.wait([
          getWeeklyAnalytics(),
          getMostOrderedProduct(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final analytics = snapshot.data![0] as Map<String, dynamic>;
          final topProduct = snapshot.data![1] as Map<String, dynamic>?;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ملخص التقييمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('عدد التقييمات هذا الأسبوع: ${analytics['totalRatings']}'),
                      Text('عدد التقييمات الأسبوع الماضي: ${analytics['lastWeekRatings']}'),
                      const SizedBox(height: 10),
                      Text('أعلى تقييم: ${analytics['highestCategory']} ✨'),
                      Text('أقل تقييم: ${analytics['lowestCategory']} ❤'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (topProduct != null)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(topProduct['productImage'], height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('المنتج الأكثر طلبًا', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(topProduct['productDescription']),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Stream<int> stream;
  final VoidCallback onTap;

  const DashboardCard({
    required this.title,
    required this.icon,
    required this.stream,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.teal),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              StreamBuilder<int>(
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  return Text('${snapshot.data}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// باقي الصفحات المؤقتة


class PostsDetailsPage extends StatelessWidget {
  const PostsDetailsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تفاصيل المنشورات')), body: const Center(child: Text('قائمة المنشورات')));
}

class OrdersDetailsPage extends StatelessWidget {
  const OrdersDetailsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تفاصيل الطلبات')), body: const Center(child: Text('قائمة الطلبات')));
}

class RatingsDetailsPage extends StatelessWidget {
  const RatingsDetailsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تفاصيل التقييمات')), body: const Center(child: Text('قائمة التقييمات')));
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الإشعارات')), body: const Center(child: Text('إرسال إشعارات')));
}

class AdminPostsPage extends StatelessWidget {
  const AdminPostsPage({super.key});

  void _deletePost(String postId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المنشور')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الحذف: $e')),
      );
    }
  }

  void _toggleVisibility(String postId, bool currentStatus, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'isHidden': !currentStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(!currentStatus ? 'تم حجب المنشور' : 'تم إلغاء الحجب')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في التحديث: $e')),
      );
    }
  }

  void _editPost(BuildContext context, DocumentSnapshot postDoc) {
    final descController = TextEditingController(text: postDoc['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المنشور'),
        content: TextField(
          controller: descController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'الوصف'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postDoc.id)
                  .update({'description': descController.text});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث المنشور')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addPost(BuildContext context) {
    final imageUrlController = TextEditingController();
    final descController = TextEditingController();
    final storeNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منشور جديد'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'رابط الصورة'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: storeNameController,
                decoration: const InputDecoration(labelText: 'اسم المتجر'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final newPost = {
                'postUrl': imageUrlController.text.trim(),
                'description': descController.text.trim(),
                'storeName': storeNameController.text.trim(),
                'datePublished': Timestamp.now(),
                'isHidden': false,
              };

              try {
                await FirebaseFirestore.instance.collection('posts').add(newPost);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة المنشور')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ في الإضافة: $e')),
                );
              }
            },
            child: const Text('نشر'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنشورات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addPost(context),
            tooltip: 'إضافة منشور',
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final posts = snapshot.data!.docs;
          if (posts.isEmpty) return const Center(child: Text('لا توجد منشورات حالياً.'));

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: posts.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final post = posts[index];

              final data = post.data() as Map<String, dynamic>?;

              final postUrl = data?['postUrl'] ?? '';
              final description = data?['description'] ?? 'بدون وصف';
              final storeName = data?['storeName'] ?? data?['uid'] ?? 'مستخدم غير معروف';
              final isHidden = data?['isHidden'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (postUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          postUrl,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const SizedBox(
                            height: 200,
                            child: Center(child: Icon(Icons.broken_image, size: 80)),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('الناشر: $storeName', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _editPost(context, post),
                              ),
                              IconButton(
                                icon: Icon(
                                  isHidden ? Icons.visibility_off : Icons.visibility,
                                  color: isHidden ? Colors.red : Colors.green,
                                ),
                                onPressed: () => _toggleVisibility(post.id, isHidden, context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePost(post.id, context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RatedStoresPage extends StatefulWidget {
  const RatedStoresPage({super.key});

  @override
  State<RatedStoresPage> createState() => _RatedStoresPageState();
}

class _RatedStoresPageState extends State<RatedStoresPage> {
  double _minRating = 0;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتاجر المقيّمة'),
        actions: [
          PopupMenuButton<double>(
            onSelected: (value) {
              setState(() {
                _minRating = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text("كل التقييمات")),
              const PopupMenuItem(value: 4.0, child: Text("4.0 وأعلى")),
              const PopupMenuItem(value: 4.5, child: Text("4.5 وأعلى")),
              const PopupMenuItem(value: 5.0, child: Text("5.0 فقط")),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('storeRatings')
            .orderBy('averageRating', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final allDocs = snapshot.data!.docs;

          final filteredDocs = allDocs.where((doc) {
            final rating = doc['averageRating'];
            return rating != null && rating is num && rating >= _minRating;
          }).toList();

          final topRatedThisMonth = allDocs.where((doc) {
            final rating = doc['averageRating'];
            final published = doc['timestamp'];
            if (rating == null || published == null || rating is! num || published is! Timestamp) return false;
            return (published.toDate().isAfter(startOfMonth));
          }).fold<DocumentSnapshot?>(null, (prev, current) {
            if (prev == null) return current;
            return (current['averageRating'] ?? 0) > (prev['averageRating'] ?? 0) ? current : prev;
          });

          return ListView(
            children: [
              if (topRatedThisMonth != null)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(topRatedThisMonth.id)
                      .get(),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData) return const SizedBox();

                    final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {};
                    final storeName = userData['storeName'] ?? 'متجر غير معروف';
                    final storeImage = userData['profileImage'] ?? '';
                    final rating = topRatedThisMonth['averageRating']?.toStringAsFixed(1) ?? '-';

                    return Card(
                      color: Colors.amber.shade100,
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: storeImage.isNotEmpty
                              ? NetworkImage(storeImage)
                              : const AssetImage('assets/placeholder.png') as ImageProvider,
                        ),
                        title: Text('🎉 الأعلى تقييماً هذا الشهر'),
                        subtitle: Text('$storeName - ⭐ $rating'),
                      ),
                    );
                  },
                ),

              if (filteredDocs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('لا توجد تقييمات تطابق الفلتر.')),
                )
              else
                ...filteredDocs.map((doc) {
                  final rating = doc.data() as Map<String, dynamic>;
                  final uid = doc.id;

                  final averageRating = (rating['averageRating'] is num)
                      ? (rating['averageRating'] as num).toStringAsFixed(1)
                      : '-';
                  final productQuality = rating['productQuality']?.toString() ?? '-';
                  final commitment = rating['commitment']?.toString() ?? '-';
                  final interactionStyle = rating['interactionStyle']?.toString() ?? '-';
                  final totalRatings = rating['totalRatings']?.toString() ?? '-';

                  final timestamp = rating['timestamp'] is Timestamp
                      ? DateFormat('yyyy/MM/dd').format((rating['timestamp'] as Timestamp).toDate())
                      : '-';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) return const SizedBox();

                      final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

                      final storeName = userData?['storeName'] ?? 'متجر غير معروف';
                      final storeImage = userData?['photoUrl'] ?? '';

                      return ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: storeImage.isNotEmpty
                              ? NetworkImage(storeImage)
                              : const AssetImage('assets/placeholder.png') as ImageProvider,
                          radius: 25,
                        ),
                        title: Text(storeName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('⭐ $averageRating  |  عدد التقييمات: $totalRatings'),
                            Text('الجودة: $productQuality | الالتزام: $commitment | التفاعل: $interactionStyle'),
                            Text('آخر تقييم: $timestamp'),
                          ],
                        ),
                        children: [
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('storeRatings')
                                .doc(uid)
                                .collection('raters')
                                .get(),
                            builder: (context, ratersSnapshot) {
                              if (!ratersSnapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final raters = ratersSnapshot.data!.docs;

                              if (raters.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("لا توجد بيانات مقيمين محفوظة."),
                                );
                              }

                              return Column(
                                children: raters.map((raterDoc) {
                                  final raterData = raterDoc.data() as Map<String, dynamic>;
                                  final raterName = raterData['name'] ?? 'مستخدم غير معروف';
                                  final raterRating = raterData['averageRating']?.toStringAsFixed(1) ?? '-';
                                  final ratedAt = raterData['timestamp'] is Timestamp
                                      ? DateFormat('yyyy/MM/dd').format((raterData['timestamp'] as Timestamp).toDate())
                                      : '-';

                                  return ListTile(
                                    title: Text(raterName),
                                    subtitle: Text('⭐ $raterRating - $ratedAt'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("تأكيد الحذف"),
                                            content: const Text("هل أنت متأكد من حذف هذا التقييم؟"),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
                                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("حذف")),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await FirebaseFirestore.instance
                                              .collection('storeRatings')
                                              .doc(uid)
                                              .collection('raters')
                                              .doc(raterDoc.id)
                                              .delete();
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class UsersDetailsPage extends StatelessWidget {
  const UsersDetailsPage({super.key});

  void _deleteUser(String userId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المستخدم')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحذف: $e')),
        );
      }
    }
  }

  void _editUser(BuildContext context, DocumentSnapshot userDoc) {
    final storeNameController = TextEditingController(text: userDoc['storeName']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المستخدم'),
        content: TextField(
          controller: storeNameController,
          decoration: const InputDecoration(labelText: 'اسم المتجر'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userDoc.id)
                  .update({'storeName': storeNameController.text});
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث البيانات')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addUser(BuildContext context) {
    final storeNameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مستخدم جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: storeNameController,
              decoration: const InputDecoration(labelText: 'اسم المتجر'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final storeName = storeNameController.text.trim();
              final email = emailController.text.trim();

              if (storeName.isNotEmpty && email.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').add({
                  'storeName': storeName,
                  'email': email,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إضافة المستخدم')),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المستخدمين'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _addUser(context),
              tooltip: 'إضافة مستخدم',
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!.docs;
            if (users.isEmpty) {
              return const Center(child: Text('لا يوجد مستخدمين حاليًا.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    title: Text(
                      user['storeName'] ?? 'بدون اسم',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('ID: ${user.id}'),
                    trailing: Wrap(
                      spacing: 12,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editUser(context, user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user.id, context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AdminDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لوحة تحكم المشرف',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      scrollBehavior: MyCustomScrollBehavior(), // ✅ هذا السطر مضاف
      home: DashboardScreen(),
    );
  }
}
