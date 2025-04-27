import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/homePage/post.dart';

class TaggedView extends StatefulWidget {
  final bool isCurrentUser;

  const TaggedView({Key? key, required this.isCurrentUser}) : super(key: key);

  @override
  State<TaggedView> createState() => _TaggedViewState();
}

class _TaggedViewState extends State<TaggedView> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (!widget.isCurrentUser) {
      return const SizedBox();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('savedBy', arrayContains: currentUserId)
          .orderBy('datePublished', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('حدث خطأ أثناء تحميل المنشورات المحفوظة'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('لا توجد منشورات محفوظة'));
        }

        final filteredPosts = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isDeleted'] != true &&
              (data['savedBy'] as List<dynamic>).contains(currentUserId);
        }).map((doc) => Post.fromSnap(doc)).toList();

        if (filteredPosts.isEmpty) {
          return const Center(child: Text('لا توجد منشورات محفوظة'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            final post = filteredPosts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: PostWidget(
                  key: ValueKey(post.postId),
                  post: post,
                  currentUserId: currentUserId ?? '',
                  onLike: () => _handleLike(post),
                  onSave: () => _confirmUnsave(post),
                  onDelete: () => _handleDelete(post),
                  onRestore: () => _handleRestore(post),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // تأكيد إلغاء الحفظ
  void _confirmUnsave(Post post) async {
    final isSaved = post.savedBy.contains(currentUserId);

    if (isSaved) {
      final shouldUnsave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد'),
          content: const Text('هل تريد إلغاء حفظ هذا المنشور؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('لا'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('نعم'),
            ),
          ],
        ),
      );

      if (shouldUnsave == true) {
        _handleSave(post);
      }
    } else {
      _handleSave(post); // في حال ما كان محفوظ، فقط نحفظه
    }
  }

  // التعامل مع اللايك
  void _handleLike(Post post) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.postId);
    final isLiked = post.likes.contains(currentUserId);
    await postRef.update({
      'likes': isLiked
          ? FieldValue.arrayRemove([currentUserId])
          : FieldValue.arrayUnion([currentUserId]),
    });
  }

  // التعامل مع الحفظ وإلغاء الحفظ
  void _handleSave(Post post) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.postId);
    final isSaved = post.savedBy.contains(currentUserId);
    await postRef.update({
      'savedBy': isSaved
          ? FieldValue.arrayRemove([currentUserId])
          : FieldValue.arrayUnion([currentUserId]),
    });
  }

  // حذف المنشور (إخفاء)
  void _handleDelete(Post post) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId)
        .update({'isDeleted': true});
  }

  // استرجاع المنشور
  void _handleRestore(Post post) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId)
        .update({'isDeleted': false});
  }
}
