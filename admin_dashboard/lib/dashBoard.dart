import 'package:admin_dashboard/analisticss.dart';
import 'package:admin_dashboard/users/posts.dart';
import 'package:admin_dashboard/users/rating.dart';
import 'package:admin_dashboard/users/users_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
