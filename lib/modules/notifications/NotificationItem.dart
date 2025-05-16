import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationItem extends StatefulWidget {
  final String username;
  final String action;
  final String time;
  final String? postImage; // صورة المنشور (اختياري)
  final String avatarUrl;
  final bool showButton;
  final bool isSystemNotification; // إشعارات من النظام
  final bool isImageFromNetwork; // لتحديد مصدر صورة البروفايل

  // خصائص خاصة بزر رد المتابعة
  final Future<void> Function()? onFollowBackPressed;
  final bool isFollowed; // هل تمت المتابعة؟

  const NotificationItem({
    Key? key,
    required this.username,
    required this.action,
    required this.time,
    required this.avatarUrl,
    this.postImage,
    required this.showButton,
    this.isSystemNotification = false,
    this.isImageFromNetwork = false,
    this.onFollowBackPressed,
    this.isFollowed = false, // افتراضي غير متابع
  }) : super(key: key);

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  late bool _isFollowed;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.isFollowed;
  }

  Future<void> _handleFollowBack() async {
    if (_isFollowed || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.onFollowBackPressed != null) {
        await widget.onFollowBackPressed!();
      }
      setState(() {
        _isFollowed = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الرد على المتابعة')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // لو الإشعار من النظام، نظهر فقط النص بدون صورة بروفايل
          if (widget.isSystemNotification)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.action,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    widget.time,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            )
          else
            // إشعار عادي: صورة البروفايل + النص
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: widget.avatarUrl.isNotEmpty &&
                          widget.avatarUrl.startsWith('http')
                      ? CachedNetworkImageProvider(widget.avatarUrl)
                      : const AssetImage('assets/default_user.png')
                          as ImageProvider,
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.username} ${widget.action}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      widget.time,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),

          // صورة المنشور أو زر الرد أو عبارة "تم المتابعة" أو مساحة فارغة
          if (widget.postImage != null && widget.postImage!.isNotEmpty)
            Container(
              width: 85,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.postImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
            )
          else if (widget.showButton && !_isFollowed)
            GestureDetector(
              onTap: _handleFollowBack,
              child: Container(
                width: 101,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade600],
                        )
                      : const LinearGradient(
                          colors: [Colors.purple, Colors.deepPurpleAccent],
                        ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'رد المتابعة',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )
          else if (_isFollowed)
            Container(
              width: 101,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade400, const Color.fromARGB(255, 244, 206, 206)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'تم ردالمتابعه',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(width: 85, height: 75),
        ],
      ),
    );
  }
}
