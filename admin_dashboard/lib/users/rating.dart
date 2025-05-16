import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
