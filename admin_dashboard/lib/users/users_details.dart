import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
