import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/shared/components/constants.dart';

class Comments extends StatefulWidget {
  final String postId;

  const Comments({super.key, required this.postId});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController _commentController = TextEditingController();
  Map<String, bool> _replyVisible = {};
  Map<String, TextEditingController> _replyControllers = {};

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) {
      // لا ترسل تعليق فارغ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يمكن إرسال تعليق فارغ')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final userData = userDoc.data();
    if (userData == null) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'name': userData['storeName'] ?? 'مستخدم',
      'time': Timestamp.now(),
      'image': userData['profileImage'] ?? '',
      'text': _commentController.text.trim(),
      'uid': currentUser.uid,
      'likes': [],
      'replies': [],
    });

    _commentController.clear(); // تنظيف حقل التعليق بعد الإرسال
  }
  void _toggleLike(String commentId, bool isLiked) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    await commentRef.update({
      'likes': isLiked
          ? FieldValue.arrayRemove([currentUser.uid])
          : FieldValue.arrayUnion([currentUser.uid]),
    });
  }

  void _showReplyInput(String commentId) {
    setState(() {
      _replyVisible[commentId] = !(_replyVisible[commentId] ?? false);
      _replyControllers.putIfAbsent(commentId, () => TextEditingController());
    });
  }

  void _sendReply(String commentId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final replyText = _replyControllers[commentId]?.text.trim();
    if (replyText == null || replyText.isEmpty) return;

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    await commentRef.update({
      'replies': FieldValue.arrayUnion([
        {
          'uid': currentUser.uid,
          'text': replyText,
          'time': Timestamp.now(),
        }
      ])
    });

    _replyControllers[commentId]?.clear();
  }

  void _deleteReplyFromComment(String commentId, Map<String, dynamic> reply) async {
    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    await commentRef.update({
      'replies': FieldValue.arrayRemove([reply]),
    });
  }

  Widget _buildReplyInput(String commentId) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyControllers[commentId],
              decoration: InputDecoration(
                hintText: 'اكتب رد...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => _sendReply(commentId),
          ),
        ],
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التعليقات'),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .collection('comments')
                .snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.comment_outlined),
                    SizedBox(width: 5),
                    Text('$count'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: MyColor.lightprimaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 20),
                    child: Container(
                      width: 79,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D6D6),
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('comments')
                          .orderBy('time', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final comments = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final data = comments[index];
                            final commentData = data.data() as Map<String, dynamic>;
                            return _buildListItem(
                              commentData['name'],
                              _formatTime(commentData['time']),
                              commentData['image'],
                              commentData['text'],
                              data.id,
                              commentData.containsKey('uid') ? commentData['uid'] : '',
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _buildCommentInput(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String name, String time, String imageUrl, String text, String commentId, String userId) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        final commentData = snapshot.data!.data() as Map<String, dynamic>;
        final likes = commentData['likes'] ?? [];
        final replies = commentData['replies'] ?? [];
        final isLiked = likes.contains(currentUser?.uid);

        return ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: userId),
              ));
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : AssetImage('assets/images/2.png') as ImageProvider,
            ),
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: userId),
              ));
            },
            child: Text(name),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text),
              Row(
                children: [
                  Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _toggleLike(commentId, isLiked),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('${likes.length}', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showReplyInput(commentId),
                    child: Text('رد (${replies.length})', style: TextStyle(fontSize: 12, color: MyColor.blueColor)),
                  ),
                ],
              ),
              if (_replyVisible[commentId] == true) _buildReplyInput(commentId),
              if (_replyVisible[commentId] == true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(replies.length, (index) {
                    final reply = replies[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(reply['text'] ?? '')),
                          if (reply['uid'] == currentUser?.uid)
                            IconButton(
                              icon: Icon(Icons.delete, size: 16, color: Colors.red),
                              onPressed: () => _deleteReplyFromComment(commentId, reply),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
            ],
          ),
          trailing: userId == currentUser?.uid
              ? PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('حذف'),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.postId)
                            .collection('comments')
                            .doc(commentId)
                            .delete();
                      },
                    ),
                  ],
                )
              : SizedBox(width: 0),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      color: MyColor.lightprimaryColor,
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    blurRadius: 9,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      String img = 'assets/images/2.png';
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        img = data['profileImage'] ?? img;
                      }
                      return CircleAvatar(
                        backgroundImage: img.startsWith('http')
                            ? NetworkImage(img)
                            : AssetImage(img) as ImageProvider,
                        radius: 18,
                      );
                    },
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'اكتب تعليق...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendComment,
                    child: Icon(Icons.send_outlined, color: MyColor.pinkColor),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return 'قبل ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'قبل ${difference.inHours} ساعة';
    return '${date.day}/${date.month}/${date.year}';
  }
}
