import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
