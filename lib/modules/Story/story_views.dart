import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:intl/intl.dart';

class StoryViewersPage extends StatelessWidget {
  final String storyId;

  const StoryViewersPage({Key? key, required this.storyId}) : super(key: key);

  Future<List<Users>> _fetchViewers() async {
    try {
      final storyDoc = await FirebaseFirestore.instance
          .collection('stories')
          .doc(storyId)
          .get();

      if (!storyDoc.exists) return [];

      final views = (storyDoc.data()?['views'] as Map<String, dynamic>? ?? {})
          .cast<String, dynamic>();

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final viewerIds = views.keys.where((id) => id != currentUserId).toList();

      if (viewerIds.isEmpty) return [];

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: viewerIds)
          .get();

      return usersSnapshot.docs.map((doc) => Users.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ خطأ أثناء جلب المشاهدات: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
         flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text('مشاهدات اليومية',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: MyColor.lightprimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: MyColor.lightprimaryColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12.0 : 24.0,
          vertical: 8.0,
        ),
        child: FutureBuilder<List<Users>>(
          future: _fetchViewers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            MyColor.lightprimaryColor)),
                    const SizedBox(height: 16),
                    Text('جاري تحميل المشاهدات...',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16 * textScaleFactor,
                        )),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ أثناء جلب البيانات',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 18 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الرجاء المحاولة مرة أخرى',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14 * textScaleFactor,
                      ),
                    ),
                  ],
                ),
              );
            }

            final viewers = snapshot.data ?? [];

            if (viewers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_red_eye_outlined,
                        size: 48, color: Colors.black26),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد مشاهدات بعد',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيظهر المشاهدون هنا بمجرد مشاهدة اليومية',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14 * textScaleFactor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'عدد المشاهدين: ${viewers.length}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: viewers.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    itemBuilder: (context, index) {
                      final user = viewers[index];
                      return _ViewerCard(
                          user: user, isSmallScreen: isSmallScreen);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ViewerCard extends StatelessWidget {
  final Users user;
  final bool isSmallScreen;

  const _ViewerCard({
    required this.user,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // يمكنك إضافة عمل عند النقر على البطاقة
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8.0 : 16.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 24 : 28,
                backgroundImage: NetworkImage(
                  user.profileImage ?? 'https://via.placeholder.com/150',
                ),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.storeName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isSmallScreen ? 16 : 18 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.displayName ?? user.email ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallScreen ? 14 : 15 * textScaleFactor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
