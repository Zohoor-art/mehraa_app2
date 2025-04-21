import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/shared/components/constants.dart';
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
  bool _isExpanded = false;
  bool _isHovering = false;
  bool _isVideoInitialized = false;
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isDeleting = false;

  Map<String, dynamic>? _userData;
  bool _isUserDataLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoIfNeeded();
    _loadUserData();
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
      CircleAvatar(
        radius: 20, // صغر الحجم هنا
        backgroundImage: _isUserDataLoading
            ? null
            : NetworkImage(_userData?['profileImage'] ?? ''),
        child: _isUserDataLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),

      SizedBox(width: 10),

      // الاسم والموقع
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userData?['storeName'] ?? 'تحميل...',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            // Text(
            //   widget.post.location,
            //   style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            // ),
          ],
        ),
      ),

      // الخيارات
      isCurrentUserPost
          ? _buildPostOwnerOptions()
          : IconButton(
              icon: Icon(Icons.more_vert, size: 18),
              onPressed: _showPostOptions,
            ),
    ],
  ),
),

_buildPostContent(),
          // Interaction Buttons
          Padding(
            padding: const EdgeInsets.only(top: 8),
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
            
                _buildInteractionButton(
                  icon: SvgPicture.asset(
                    'assets/images/comment.svg',
                    color: Colors.deepPurple,
                    width: 28,
                    height: 28,
                  ),
                  countText: widget.post.commentCount.toString(),
                  onPressed: _openComments,
                ),
                SizedBox(width: 16),
            
                _buildInteractionButton(
                  icon: SvgPicture.asset(
                    'assets/images/share.svg',
                    color: Colors.deepPurple,
                    width: 25,
                    height: 25,
                  ),
                  countText:widget. post.shareCount.toString(), // تأكد أنك عندك هذي القيمة
                  onPressed: _sharePost,
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

  if (widget.post.videoUrl.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // 👈 هنا زاوية الفيديو
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _isVideoInitialized
            ? Chewie(controller: _chewieController!)
            : Center(child: CircularProgressIndicator()),
      ),
    );
  } else {
    return GestureDetector(
      onTap: _openPostDetail,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // 👈 هنا زاوية الصورة
        child: Container(
          height: 300,
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
    child: AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isHovering ? const Color.fromARGB(255, 232, 211, 250).withOpacity(0.05) : const Color.fromARGB(255, 214, 189, 233).withOpacity(0.05),
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
              child: Icon(Icons.shopping_cart, color: Colors.white, size: 16),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'طلب المنتج',
            style: TextStyle(color: Colors.white),
          ),
        ],
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
        color: const Color.fromARGB(255, 216, 195, 239).withOpacity(0.2),
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
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.report, color: Colors.red),
            title: Text('إبلاغ عن المنشور'),
            onTap: () {
              Navigator.pop(context);
              _reportPost();
            },
          ),
          ListTile(
            leading: Icon(Icons.share, color: Colors.blue),
            title: Text('مشاركة المنشور'),
            onTap: () {
              Navigator.pop(context);
              _sharePost();
            },
          ),
          ListTile(
            leading: Icon(Icons.copy, color: Colors.grey),
            title: Text('نسخ رابط المنشور'),
            onTap: () {
              Navigator.pop(context);
              _copyPostLink();
            },
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
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

  void _reportPost() {
    // TODO: Implement report functionality
  }

  void _copyPostLink() {
    // TODO: Implement copy link functionality
  }

  String _formatDate(Timestamp timestamp) {
    return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
  }
}
