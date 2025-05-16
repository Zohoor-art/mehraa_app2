import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/comments/comments.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/modules/reels/gift_screen.dart';
import 'package:mehra_app/modules/sharing/sharing.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/components/post_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class OptionsScreen extends StatefulWidget {
  final Post post;
  final String currentUserId;
  final VoidCallback? onFollow;
  final VoidCallback? onSave;

  const OptionsScreen({
    Key? key,
    required this.post,
    required this.currentUserId,
    this.onFollow,
    this.onSave,
  }) : super(key: key);

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool _isFollowing = false;
  bool _isLoadingFollow = false;
  bool _isLiked = false;
  bool _isLiking = false;
  int _likeCount = 0;
  Map<String, dynamic>? _userData;
  bool _isUserDataLoading = true;
  String? _taskId;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes.length;
    _isLiked = widget.post.likes.contains(widget.currentUserId);
    _checkIfFollowing();
    _loadUserData();
    _initDownloader();
  }

  Future<void> _initDownloader() async {
    // await FlutterDownloader.initialize(debug: true);
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.post.uid)
          .get();

      if (mounted) {
        setState(() {
          _userData = userDoc.data();
          _isUserDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUserDataLoading = false;
        });
      }
    }
  }

  Future<void> _checkIfFollowing() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('following')
        .doc(widget.post.uid)
        .get();

    if (mounted) {
      setState(() {
        _isFollowing = doc.exists;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    setState(() => _isLiking = true);

    try {
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId);

      if (_isLiked) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([widget.currentUserId])
        });
        setState(() {
          _isLiked = false;
          _likeCount--;
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([widget.currentUserId])
        });
        setState(() {
          _isLiked = true;
          _likeCount++;
        });

        if (widget.post.uid != widget.currentUserId) {
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(widget.post.uid)
              .collection('userNotifications')
              .add({
            'type': 'like',
            'fromUserId': widget.currentUserId,
            'postId': widget.post.postId,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLiking = false);
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoadingFollow) return;
    setState(() => _isLoadingFollow = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      if (_isFollowing) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('following')
            .doc(widget.post.uid)
            .delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.post.uid)
            .collection('followers')
            .doc(currentUser.uid)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('following')
            .doc(widget.post.uid)
            .set({'followedAt': Timestamp.now()});

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.post.uid)
            .collection('followers')
            .doc(currentUser.uid)
            .set({'followedAt': Timestamp.now()});

        if (widget.post.uid != widget.currentUserId) {
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(widget.post.uid)
              .collection('userNotifications')
              .add({
            'type': 'follow',
            'fromUserId': widget.currentUserId,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      }

      if (mounted) {
        setState(() => _isFollowing = !_isFollowing);
      }
      widget.onFollow?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingFollow = false);
      }
    }
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
            },
          ),
        ],
      ),
    );
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
                  _buildActionIcon(Icons.link, 'نسخ الرابط',
                      [Color(0xFFE91E63), Color(0xFF4A148C)], () {
                    Navigator.pop(context);
                    PostActions.copyLink(context, widget.post.postId);
                  }),
                  _buildActionIcon(Icons.share, 'مشاركة',
                      [Color(0xFFE91E63), Color(0xFF4A148C)], () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => Sharing(
                        postImageUrl: widget.post.postUrl,
                        postId: widget.post.postId, 
                        postDescription: widget.post.description,
                      ),
                    );
                  }),
                  _buildActionIcon(Icons.report, 'إبلاغ',
                      [Color(0xFFBD4037), Color(0xFFED1404)], () {
                    Navigator.pop(context);
                    PostActions.reportPost(context, widget.post.postId);
                  }),
                ],
              ),
              SizedBox(height: 24),
              if (_isFollowing)
                _buildOptionTile(Icons.person_remove, 'إلغاء المتابعة',
                    () async {
                  Navigator.pop(context);
                  await PostActions.unfollowUser(context, widget.post.uid);
                  setState(() {
                    _isFollowing = false;
                  });
                }),
              _buildOptionTile(Icons.visibility_off, 'إخفاء', () {
                Navigator.pop(context);
                PostActions.hidePost(context, widget.post.postId);
              }),
              _buildOptionTile(Icons.person, 'عن هذا الحساب', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: widget.post.uid),
                  ),
                );
              }),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _shareViaApps(String url) async {
    try {
      await Share.share(
        'شاهد هذا الفيديو الرائع من تطبيق مهرة',
        subject: 'مشاركة فيديو من تطبيق مهرة',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل المشاركة: ${e.toString()}')),
      );
    }
  }

  Future<void> _copyVideoLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ الرابط بنجاح')),
    );
  }


  Widget _buildActionIcon(IconData icon, String label,
      List<Color> gradientColors, VoidCallback onTap) {
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
      onTap: onTap,
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  TextStyle _getTextStyleWithShadow() {
    return TextStyle(color: Colors.white, shadows: [
      Shadow(
        blurRadius: 10.0,
        color: Colors.black,
        offset: Offset(1.0, 1.0),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUserPost = widget.post.uid == widget.currentUserId;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 100),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(userId: widget.post.uid),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(widget.post.profileImage),
                            radius: 16,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          widget.post.storeName,
                          style: _getTextStyleWithShadow(),
                        ),
                        SizedBox(width: 10),
                        if (!isCurrentUserPost)
                          _isLoadingFollow
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : TextButton(
                                  onPressed: _isFollowing
                                      ? _showReviewDialog
                                      : _toggleFollow,
                                  style: TextButton.styleFrom(
                                    backgroundColor: _isFollowing
                                        ? Colors.grey[300]
                                        : Colors.black.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    _isFollowing ? 'تقييم' : 'متابعة',
                                    style: _getTextStyleWithShadow().copyWith(
                                      color: _isFollowing
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                      ],
                    ),
                    SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textSpan = TextSpan(
                          text: widget.post.description,
                          style: _getTextStyleWithShadow(),
                        );
                        
                        final textPainter = TextPainter(
                          text: textSpan,
                          maxLines: 2,
                          textDirection: TextDirection.rtl,
                        )..layout(maxWidth: constraints.maxWidth);
                        
                        final isTextLong = textPainter.didExceedMaxLines;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                textSpan,
                                maxLines: _isExpanded ? null : 2,
                                overflow: _isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              if (isTextLong && !_isExpanded)
                                Text(
                                  '...المزيد',
                                  style: _getTextStyleWithShadow().copyWith(
                                    color: Colors.grey[300],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_sharp,
                          color: MyColor.blueColor,
                          size: 20,
                        ),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.post.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(
                                'جاري التحميل...',
                                style: _getTextStyleWithShadow(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text(
                                'فشل تحميل الموقع',
                                style: _getTextStyleWithShadow(),
                              );
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Text(
                                'لا يوجد موقع',
                                style: _getTextStyleWithShadow(),
                              );
                            }

                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final storeLocation = userData['location'] ??
                                'غير محدد';

                            return Text(
                              storeLocation,
                              style: _getTextStyleWithShadow(),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.music_note,
                          color: MyColor.blueColor,
                          size: 20,
                        ),
                        Text(
                          'الصوت الأصلي',
                          style: _getTextStyleWithShadow(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftsScreen(
                              postId: widget.post.postId,
                              receiverId: widget.post.uid,
                              receiverName: widget.post.storeName,
                            ),
                          ),
                        );
                      },
                      icon: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            MyColor.blueColor,
                            MyColor.purpleColor,
                            MyColor.pinkColor
                          ],
                        ).createShader(bounds),
                        child: FaIcon(
                          FontAwesomeIcons.gift,
                          size: 25.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('gifts')
                          .where('postId', isEqualTo: widget.post.postId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final giftCount =
                            snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text(
                          _formatCount(giftCount),
                          style: _getTextStyleWithShadow(),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          MyColor.blueColor,
                          MyColor.purpleColor,
                          MyColor.pinkColor
                        ],
                      ).createShader(bounds),
                      child: IconButton(
                        icon: _isLiking
                            ? SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 33.0,
                                color: _isLiked ? Colors.red : Colors.white,
                              ),
                        onPressed: _toggleLike,
                      ),
                    ),
                    Text(
                      _formatCount(_likeCount),
                      style: _getTextStyleWithShadow(),
                    ),
                    SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          MyColor.blueColor,
                          MyColor.purpleColor,
                          MyColor.pinkColor
                        ],
                      ).createShader(bounds),
                      child: IconButton(
                        icon: Icon(
                          Icons.mode_comment_outlined,
                          size: 25.0,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Comments(postId: widget.post.postId),
                            ),
                          );
                        },
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.post.postId)
                          .collection('comments')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final commentCount =
                            snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text(
                          _formatCount(commentCount),
                          style: _getTextStyleWithShadow(),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Transform(
                      transform: Matrix4.rotationZ(6.5),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            MyColor.blueColor,
                            MyColor.purpleColor,
                            MyColor.pinkColor
                          ],
                        ).createShader(bounds),
                        child: IconButton(
                          icon:
                              Icon(Icons.send, size: 25.0, color: Colors.white),
                          onPressed: () => _shareViaApps(widget.post.videoUrl),
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onPressed: _showPostOptions,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}