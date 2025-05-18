import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class UsersDetailsPage extends StatelessWidget {
  const UsersDetailsPage({super.key});

  Future<int> _getFollowersCount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('followers')
        .get();
    return snapshot.docs.length;
  }

  Future<double> _getAverageRating(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('storeRatings')
        .doc(userId)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && data['averageRating'] != null) {
        return data['averageRating'].toDouble();
      }
    }
    return 0.0;
  }

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
  final data = userDoc.data() as Map<String, dynamic>? ?? {};
  
  final storeNameController = TextEditingController(text: data['storeName'] ?? '');
  final emailController = TextEditingController(text: data['email'] ?? '');
  bool isCommercial = data['isCommercial'] == true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل المستخدم'),
          content: SingleChildScrollView(
            child: Column(
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('حساب تجاري'),
                    Checkbox(
                      value: isCommercial,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            isCommercial = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
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
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userDoc.id)
                      .update({
                    'storeName': storeName,
                    'email': email,
                    'isCommercial': isCommercial,
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث البيانات')),
                    );
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      );
    },
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

  void _showUserDetails(BuildContext context, DocumentSnapshot userDoc, int followersCount, double avgRating) {
  final data = userDoc.data() as Map<String, dynamic>? ?? {};
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تفاصيل المستخدم'),
      content: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${userDoc.id}'),
              const SizedBox(height: 8),
              Text('اسم المتجر: ${data['storeName'] ?? 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الإيميل: ${data['email'] ?? 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('عدد المتابعين: $followersCount'),
              const SizedBox(height: 8),
              Text('التقييم: ${avgRating.toStringAsFixed(1)}'),
              const SizedBox(height: 8),
              Text('نوع الحساب: ${ 
                (data['isCommercial'] == true) 
                  ? 'تجاري' 
                  : (data['provider'] == 'google' ? 'حساب جوجل' : 'غير معروف')
              }'),
              const SizedBox(height: 8),
              Text('موفر الخدمة: ${data['provider'] ?? 'غير محدد'}'),
              // أضف أي بيانات أخرى تريد عرضها هنا
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    ),
  );
}

  String _getDisplayName(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>;
    final bool isCommercial = data.containsKey('isCommercial') && data['isCommercial'] == true;
;
 
    if (isCommercial) {
      return data['storeName'] ?? 'بدون اسم';
    }
    final provider = data['provider']?.toString().toLowerCase();
    if (provider == 'google') {
      return data['displayName'] ?? 'بدون اسم';
    }
    return data['storeName'] ?? 'بدون اسم';
  }

  Widget _buildUserAvatar(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>;
    final bool isCommercial = data['isCommercial'] == true;
    final profileImage = data['profileImage']?.toString() ?? '';
    final provider = data['provider']?.toString().toLowerCase();

    // فقط إذا كان تجاري وصورة موجودة نعرضها
    if (isCommercial && profileImage.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(profileImage),
        backgroundColor: Colors.deepPurple.shade200,
      );
    }
    // إذا كان قوقل وصورة موجودة نعرضها
    if (!isCommercial && provider == 'google' && profileImage.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(profileImage),
        backgroundColor: Colors.deepPurple.shade200,
      );
    }
    // خلاف ذلك أيقونة بديلة
    return CircleAvatar(
      backgroundColor: Colors.deepPurple.shade400,
      child: const Icon(Icons.person, color: Colors.white),
    );
  }

  LinearGradient get _gradient => const LinearGradient(
        colors: [
          Color(0xFF4B0082), // بنفسجي غامق
          Color(0xFF8A2BE2), // بنفسجي فاتح
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

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
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: _gradient),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('تفاصيل المستخدمين',style: TextStyle(color: Colors.white),),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _addUser(context),
              tooltip: 'إضافة مستخدم',
              color: Colors.white,
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

                return FutureBuilder(
                  future: Future.wait([
                    _getFollowersCount(user.id),
                    _getAverageRating(user.id),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final followersCount = snapshot.data![0] as int;
                    final avgRating = snapshot.data![1] as double;
                    final displayName = _getDisplayName(user);

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  leading: _buildUserAvatar(user),
  title: Text(
    displayName,
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Builder(
    builder: (context) {
      final data = user.data() as Map<String, dynamic>?;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('ID: ${user.id}'),
          Text('الإيميل: ${user['email'] ?? 'غير محدد'}'),
          Text('عدد المتابعين: $followersCount'),
          Text('التقييم: ${avgRating.toStringAsFixed(1)}'),
          Text('نوع الحساب: ${ 
            (data != null && data.containsKey('isCommercial') && data['isCommercial'] == true) 
              ? 'تجاري' 
              : (data != null && data.containsKey('provider') && data['provider'] == 'google' 
                 ? 'حساب جوجل' 
                 : 'غير معروف')
            }'),
        ],
      );
    },
  ),
  isThreeLine: true,
  trailing: Wrap(
    spacing: 8,
    children: [
      IconButton(
        icon: const Icon(Icons.visibility),
        color: Colors.deepPurple.shade700,
        tooltip: 'عرض التفاصيل',
        onPressed: () => _showUserDetails(context, user, followersCount, avgRating),
      ),
      IconButton(
        icon: const Icon(Icons.edit),
        color: Colors.deepPurple.shade400,
        tooltip: 'تعديل',
        onPressed: () => _editUser(context, user),
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        color: Colors.deepPurple.shade900,
        tooltip: 'حذف',
        onPressed: () => _deleteUser(user.id, context),
      ),
    ],
  ),
),

                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
