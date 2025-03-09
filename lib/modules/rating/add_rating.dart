import 'package:flutter/material.dart';

class RatingsListPage extends StatefulWidget {
  @override
  _RatingsListPageState createState() => _RatingsListPageState();
}

class _RatingsListPageState extends State<RatingsListPage> {
  final List<Map<String, dynamic>> ratingsData = [
    {'name': 'متجر زهره', 'rating': 90.0},
    {'name': 'متجرنا للكيك', 'rating': 85.5},
    {'name': 'متجر لورد', 'rating': 92.0},
    {'name': 'متجر روز', 'rating': 88.5},
    {'name': 'متجر للخياطة', 'rating': 99.0},
    {'name': 'متجر للخياطة', 'rating': 98.0},
    {'name': 'متجر للخياطة', 'rating': 77.0},
    {'name': 'متجر للخياطة', 'rating': 96.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Align(
        alignment: Alignment(0, 1.15), // لضبط الكارد في منتصف الشاشة
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            child: SingleChildScrollView( 
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'التفاصيل',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  ...ratingsData.map((data) {
                    return ListTile(
                      title: Text(
                        data['name'],
                        style: TextStyle(fontSize: 20),
                      ),
                      trailing: Text(
                        '${data['rating']}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}