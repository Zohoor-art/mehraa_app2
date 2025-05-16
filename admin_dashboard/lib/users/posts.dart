import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
