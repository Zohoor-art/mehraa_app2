import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoresByRegionScreen extends StatelessWidget {
  final String location;

  const StoresByRegionScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المتاجر في $location')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('location', isEqualTo: location)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد متاجر في هذه المنطقة.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['storeName'] ?? 'بدون اسم'),
                  subtitle: Text(data['location'] ?? 'بدون موقع'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
