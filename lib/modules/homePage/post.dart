import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/chats/chat_room.dart';
import 'package:mehra_app/modules/comments/comments.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/modules/rating/rating.dart';
import 'package:mehra_app/modules/sharing/sharing.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/components/post_actions.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PostWidget extends StatefulWidget {
  final Post post;
 
  final String currentUserId;
  final VoidCallback? onDelete;
  final VoidCallback? onRestore;
  final VoidCallback? onLike;
  final VoidCallback? onSave;

  const PostWidget({
    Key? key,
    required this.post,
    
    required this.currentUserId,
    this.onDelete,
    this.onRestore,
    this.onLike,
    this.onSave,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
   bool isFollowing =false;
  bool _isExpanded = false;
  bool _isHovering = false;
  bool _isVideoInitialized = false;
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isDeleting = false;

  Map<String, dynamic>? _userData;
  bool _isUserDataLoading = true;
  void _toggleFollowUser() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final otherUserId = _userData?['uid'];

  if (currentUser == null || otherUserId == null) return;

  final currentUserRef = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid);

  final otherUserRef = FirebaseFirestore.instance
      .collection('users')
      .doc(otherUserId);

  final followingRef = currentUserRef.collection('following').doc(otherUserId);
  final followerRef = otherUserRef.collection('followers').doc(currentUser.uid);

  try {
    // متابعة فقط
    await followingRef.set({'followedAt': Timestamp.now()});
    await followerRef.set({'followedAt': Timestamp.now()});

    setState(() {
      isFollowing = true; // يخفي الزر
    });
  } catch (e) {
    debugPrint('Error following user: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء المتابعة')),
    );
  }
}
void checkIfFollowing() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final otherUserId = _userData?['uid'];

  if (currentUser == null || otherUserId == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .collection('following')
      .doc(otherUserId)
      .get();

  setState(() {
    isFollowing = doc.exists; // ← true إذا تتابعه
  });
}



  @override
  void initState() {
    super.initState();
    _initializeVideoIfNeeded();
    _loadUserData();
    print("Video URL: ${widget.post.videoUrl}");
  }

  void _initializeVideoIfNeeded() {
    if (widget.post.videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.network(widget.post.videoUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
              _chewieController = ChewieController(
                videoPlayerController: _videoController,
                autoPlay: false,
                looping: true,
                showControls: true,
                materialProgressColors: ChewieProgressColors(
                  playedColor: Colors.purple,
                  handleColor: Colors.pink,
                  backgroundColor: Colors.grey,
                  bufferedColor: Colors.grey[300]!,
                ),
              );
            });
          }
        });
    }
  }

  void _loadUserData() async {
    final data = await widget.post.getUserData();
    if (mounted) {
      setState(() {
        _userData = data;
        _isUserDataLoading = false;
      });
      checkIfFollowing();
    }
  }
 

// داخل _PostWidgetState
  Future<void> _createOrderAndOpenChat() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || _userData == null) return;

      // 1. التحقق من أن المستخدم الحالي ليس صاحب المنشور
      if (currentUser.uid == widget.post.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكنك طلب منتجك الخاص')),
        );
        return;
      }

      // 2. إنشاء الطلب في جدول orders الخاص بصاحب المنشور
      final orderRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.post.uid)
          .collection('orders')
          .add({
        'productDescription': widget.post.description,
        'productImage': widget.post.postUrl,
        'buyerId': currentUser.uid,
        'sellerId': widget.post.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'postId': widget.post.postId,
      });

      // 3. فتح صفحة المحادثة مع إرسال الرسالة التلقائية
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoom(
            userId: widget.post.uid,
            userName: _userData?['storeName'] ??
                _userData?['displayName'] ??
                'مستخدم',
            orderId: orderRef.id, // إرسال معرف الطلب
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إنشاء الطلب: ${e.toString()}')),
      );
    }
  }

 


  @override
  void dispose() {
    if (widget.post.videoUrl.isNotEmpty) {
      _videoController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.likes.contains(widget.currentUserId);
    final isSaved = widget.post.savedBy.contains(widget.currentUserId);
    final isCurrentUserPost = widget.post.uid == widget.currentUserId;

    return Card(
      color: MyColor.lightprimaryColor,
      margin: EdgeInsets.symmetric(vertical: 1),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // حواف بسيطة
  child: Row(
    children: [
  // الصورة
  GestureDetector(
 onTap: () {
    if (!_isUserDataLoading && _userData != null) {
      String otherUserId = _userData!['uid']; // ← هنا نجيبه
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: otherUserId),
        ),
      );
    }
  },
  child: CircleAvatar(
    radius: 25,
    backgroundImage: _isUserDataLoading
        ? null
        : NetworkImage(_userData?['profileImage'] ?? ''),
    child: _isUserDataLoading
        ? const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
  ),
),

  SizedBox(width: 10),

  // الاسم والموقع أو حالة المتابعة
  Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _userData?['storeName'] ?? 'تحميل...',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      Text(
        isCurrentUserPost
            ? 'أنت'
            : _userData?['location'] != null
                ? _userData!['location']
                : isFollowing
                    ? 'تتابعه'
                    : 'مقترح لك',
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
    ],
  ),
),


  // زر متابعة
  if (!isCurrentUserPost)
  GestureDetector(
    onTap: () {
      if (!isFollowing) {
        _toggleFollowUser(); // تنفيذ المتابعة
      } else {
        _showReviewDialog(); // عرض نافذة التقييم
      }
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFollowing
              ? [Colors.purple, Colors.pink] // تقييم
              : [Colors.pink, Colors.deepPurple],   // متابعة
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isFollowing ? 'تقييم' : 'متابعة',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    ),
  ),

  SizedBox(width: 6),

  // الخيارات
  isCurrentUserPost
      ? _buildPostOwnerOptions()
      : IconButton(
          icon: Icon(Icons.more_vert, size: 22),
          onPressed: _showPostOptions,
        ),
],

  ),
),
SizedBox(height: 5.0,),
_buildPostContent(),
          // Interaction Buttons
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildInteractionButton(
                  icon: SvgPicture.asset(
                    isLiked
            ? 'assets/images/fillHeart.svg'
            : 'assets/images/heartEmp.svg',
                    color: isLiked ? Colors.deepPurple :  Colors.deepPurple,
                    width: 25,
                    height: 25,
                  ),
                  countText: widget.post.likes.length.toString(),
                  onPressed: widget.onLike,
                ),
                SizedBox(width: 15),
            StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('posts')
      .doc(widget.post.postId)
      .collection('comments')
      .snapshots(),
  builder: (context, snapshot) {
    final commentCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

    return _buildInteractionButton(
      icon: SvgPicture.asset(
        'assets/images/comment.svg',
        color: Colors.deepPurple,
        width: 32,
        height: 32,
      ),
      countText: commentCount.toString(),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Comments(postId: widget.post.postId),
          ),
        );
      },
    );
  },
),
SizedBox(width: 16),
            
                _buildInteractionButton(
  icon: SvgPicture.asset(
    'assets/images/share.svg',
    color: Colors.deepPurple,
    width: 25,
    height: 25,
  ),
  countText: widget.post.shareCount.toString(),
  onPressed: () async {
    // 1. زيادة عداد المشاركات في Firestore
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postId)
        .update({
      'shareCount': FieldValue.increment(1),
    });

    // 2. فتح شاشة المشاركة كبوتوم شيت
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Sharing(
        postImageUrl: widget.post.postUrl,
        postId: widget.post.postId,
      ),
    );
  },
                ),
                SizedBox(width: 16),
            
                _buildInteractionButton(
                  icon: SvgPicture.asset(
                    isSaved
            ? 'assets/images/fill_save.svg'
            : 'assets/images/save.svg',
                    color: isSaved ? Colors.deepPurple : Colors.deepPurple,
                    width: 25,
                    height: 25,
                    
                  ),
                  countText: '', // زر الحفظ غالبًا ما يحتاج عدد، لكن تقدر تضيف إذا عندك
                  onPressed: widget.onSave,
                ),
              ],
            ),
          ),

          // Likes Count
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     '${widget.post.likes.length} إعجابات',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),

          // Description
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _buildDescription(),
          ),

          // Tags
          if (widget.post.tags.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.post.tags.map((tag) => _buildTag(tag)).toList(),
              ),
            ),

          // Date
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _formatDate(widget.post.datePublished),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostOwnerOptions() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete' && widget.onDelete != null) {
          _confirmDelete();
        } else if (value == 'restore' && widget.onRestore != null) {
          widget.onRestore!();
        }
      },
      itemBuilder: (BuildContext context) => [
        if (widget.post.isDeleted)
          PopupMenuItem(
            value: 'restore',
            child: Row(
              children: [
                Icon(Icons.restore, color: Colors.blue),
                SizedBox(width: 8),
                Text('استعادة المنشور'),
              ],
            ),
          )
        else
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('حذف المنشور'),
              ],
            ),
          ),
      ],
    );
  }

 Widget _buildPostContent() {
  if (_isDeleting) {
    return Container(
      height: 200,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('جاري حذف المنشور...'),
          ],
        ),
      ),
    );
  }

  if (widget.post.isVideo) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12), // زاوية الفيديو
    child: SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.width * 1.3, // زي إنستا
      child: _isVideoInitialized
          ? Chewie(controller: _chewieController!)
          : Center(child: CircularProgressIndicator()),
    ),
  );
}

  else {
    return GestureDetector(
      onTap: _openPostDetail,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // 👈 هنا زاوية الصورة
        child: Container(
          height: 350,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(widget.post.postUrl),
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              if (widget.post.postUrl.isNotEmpty &&
                  widget.post.videoUrl.isEmpty)
                _buildShoppingCartButton(),
            ],
          ),
        ),
      ),
    );
  }
}

  
  Widget _buildShoppingCartButton() {
  return Positioned(
    bottom: 16,
    right: 16,
    child: MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _createOrderAndOpenChat, // << هنا ربطنا الضغطة عالكارد كامل
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovering
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.pink, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'طلب المنتج',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


 Widget _buildInteractionButton({
  required Widget icon,
  required String countText,
  VoidCallback? onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 80,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:  Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          if (countText.isNotEmpty) ...[
            SizedBox(width: 8),
            Text(
              countText,
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ],
        ],
      ),
    ),
  );
}
void _showReviewDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('تقييم المتجر'),
      content: Text('هل تريد تقييم هذا المتجر؟'),
      actions: [
        TextButton(
          child: Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text('موافق'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>RatingCard(uid: widget.post.postUrl,),
              ),
            );
          },
        ),
      ],
    ),
  );
}


  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isExpanded
              ? widget.post.description
              : (widget.post.description.length > 100
                  ? '${widget.post.description.substring(0, 100)}...'
                  : widget.post.description),
          style: TextStyle(fontSize: 14),
        ),
        if (widget.post.description.length > 100)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'عرض أقل' : 'قراءة المزيد',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Chip(
      label: Text(tag),
      backgroundColor: Colors.purple.withOpacity(0.1),
      labelStyle: TextStyle(color: Colors.purple),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المنشور'),
        content: Text('هل أنت متأكد أنك تريد حذف هذا المنشور؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onDelete != null) {
      setState(() => _isDeleting = true);
      widget.onDelete!();
    }
  }

  void _showPostOptions() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionIcon(Icons.link, 'نسخ الرابط', [Color(0xFFE91E63), Color(0xFF4A148C)], () {
                  Navigator.pop(context);
                  PostActions.copyLink(context, widget.post.postId);
                }),
                _buildActionIcon(Icons.share, 'مشاركة', [Color(0xFFE91E63), Color(0xFF4A148C)], () {
                  Navigator.pop(context);
                  PostActions.sharePost(widget.post.postId, widget.post.shareCount);
                }),
                _buildActionIcon(Icons.report, 'إبلاغ', [Color(0xFFBD4037), Color(0xFFED1404)], () {
                  Navigator.pop(context);
                  PostActions.reportPost(context, widget.post.postId);
                }),
              ],
            ),
            SizedBox(height: 24),
            if (isFollowing)
  _buildOptionTile(Icons.person_remove, 'إلغاء المتابعة', () async {
    Navigator.pop(context);
    await PostActions.unfollowUser(context, widget.post.uid);
    setState(() {
      isFollowing = false; // عشان يرجع يظهر زر المتابعة
    });
  }),

            _buildOptionTile(Icons.visibility_off, 'إخفاء', () {
              Navigator.pop(context);
              PostActions.hidePost(context, widget.post.postId);
            }),
            _buildOptionTile(Icons.person, 'عن هذا الحساب', () {
              Navigator.pop(context);
              PostActions.goToUserProfile(context, widget.post.uid);
            }),
            SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionIcon(IconData icon, String label, List<Color> gradientColors, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: gradientColors),
          ),
          padding: EdgeInsets.all(16),
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    ),
  );
}

Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.purple),
    title: Text(title, textAlign: TextAlign.right),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );
}

  void _openPostDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('تفاصيل المنشور')),
          body: SingleChildScrollView(
            child: PostWidget(
              post: widget.post,
              currentUserId: widget.currentUserId,
              onDelete: widget.onDelete,
              onRestore: widget.onRestore,
              onLike: widget.onLike,
              onSave: widget.onSave,
            ),
          ),
        ),
      ),
    );
  }

  void _openComments() {
    // TODO: Implement comments screen
  }

  void _sharePost() {
    // TODO: Implement share functionality
  }

  

  String _formatDate(Timestamp timestamp) {
    return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
  }
}
