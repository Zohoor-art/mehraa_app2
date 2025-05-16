import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminToolsScreen extends StatefulWidget {
  const AdminToolsScreen({Key? key}) : super(key: key);

  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen> {
  bool isUpdating = false;
  String statusMessage = '';

  Future<void> fixIsVideoFlags() async {
    setState(() {
      isUpdating = true;
      statusMessage = 'جاري التحديث...';
    });

    try {
      final posts = await FirebaseFirestore.instance.collection('posts').get();
      int updatedCount = 0;

      for (final doc in posts.docs) {
        final data = doc.data();
        final isActuallyVideo = data['videoUrl'] != null && data['videoUrl'] != '';

        await doc.reference.update({
          'isVideo': isActuallyVideo,
        });

        updatedCount++;
      }

      setState(() {
        statusMessage = 'تم تحديث $updatedCount منشور بنجاح ✅';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'حدث خطأ أثناء التحديث ❌: $e';
      });
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أدوات المشرف'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isUpdating ? null : fixIsVideoFlags,
              icon: const Icon(Icons.video_settings),
              label: const Text('تحديث حالة الفيديو لكل المنشورات'),
            ),
            const SizedBox(height: 20),
            if (statusMessage.isNotEmpty)
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusMessage.contains('✅') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
