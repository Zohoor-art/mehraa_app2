import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingsListPage extends StatefulWidget {
  final String userId;
  const RatingsListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _RatingsListPageState createState() => _RatingsListPageState();
}

class _RatingsListPageState extends State<RatingsListPage> {
  int productQuality = 0;
  int interactionStyle = 0;
  int commitment = 0;
  int totalRatings = 0;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('storeRatings')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          productQuality = snapshot['productQuality'] ?? 0;
          interactionStyle = snapshot['interactionStyle'] ?? 0;
          commitment = snapshot['commitment'] ?? 0;
          totalRatings = snapshot['totalRatings'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  Widget buildStarsWithPercentage(int percentage) {
    double ratingOutOfFive = (percentage / 20); // لأن 100% = 5 نجوم
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < ratingOutOfFive.floor()) {
              return const Icon(Icons.star, color: Colors.amber, size: 20);
            } else if (index < ratingOutOfFive) {
              return const Icon(Icons.star_half, color: Colors.amber, size: 20);
            } else {
              return const Icon(Icons.star_border, color: Colors.amber, size: 20);
            }
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildDetailCard(String title, int value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: buildStarsWithPercentage(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل التقييم'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          buildDetailCard('جودة المنتج', productQuality),
          buildDetailCard('أسلوب التعامل', interactionStyle),
          buildDetailCard('الالتزام بالمواعيد', commitment),
          const SizedBox(height: 30),
          Center(
            child: Text(
              'عدد المقيمين: $totalRatings',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
