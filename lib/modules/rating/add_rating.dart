import 'package:flutter/material.dart';

class AddAating extends StatefulWidget {
  const AddAating({super.key});

  @override
  State<AddAating> createState() => _AddAatingState();
}

class _AddAatingState extends State<AddAating> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة تقييم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5, // لإضافة ظل للكارد
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // زوايا دائرية
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'قم بإضافة تقييمك:',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'اكتب تقييمك هنا',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // هنا يمكنك إضافة الكود لمعالجة التقييم
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة التقييم!')),
                    );
                  },
                  child: const Text('إرسال'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}