import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class Sharing extends StatefulWidget {
  final String postImageUrl;
  final String postId;

  const Sharing({
    super.key,
    required this.postImageUrl,
    required this.postId,
  });

  @override
  State<Sharing> createState() => _SharingState();
}

class _SharingState extends State<Sharing> {
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> followingIds = [];
  Set<String> sentUserIds = {};
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      searchQuery = q;
      filteredUsers = allUsers.where((u) {
        final name = (u['storeName'] ?? '').toLowerCase();
        return name.contains(q);
      }).toList();
    });
  }

  Future<void> fetchUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final followSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('following')
        .get();
    followingIds = followSnap.docs.map((d) => d.id).toList();

    final usersSnap =
        await FirebaseFirestore.instance.collection('users').get();
    allUsers = usersSnap.docs
        .where((d) => d.id != currentUser.uid)
        .map((d) => {'uid': d.id, ...d.data()})
        .toList();

    setState(() {
      filteredUsers = allUsers;
    });
  }

  Future<void> _sendToUser(String receiverId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final msg = _messageController.text.trim();
    await FirebaseFirestore.instance.collection('messages').add({
      'senderId': currentUser.uid,
      'receiverId': receiverId,
      'postId': widget.postId,
      'message': msg,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      sentUserIds.add(receiverId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم الإرسال')),
    );
  }

  void _copyLink() {
    final url = "https://mehra.app/post/${widget.postId}";
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ الرابط')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final followed = filteredUsers
        .where((u) => followingIds.contains(u['uid']))
        .toList();
    final suggestions = filteredUsers
        .where((u) => !followingIds.contains(u['uid']))
        .toList();

    const gradient = LinearGradient(
      colors: [Color(0xFF4B0082), Color(0xFFFF69B4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(title: Text('مشاركة')),
      body: Column(
        children: [
          // صورة البوست + مربع الرسالة
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.postImageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // مربع البحث
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ابحث عن شخص...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // قائمة المستخدمين
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (followed.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text('المتابَعون',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...followed.map(_buildUserTile),
                  ],
                  if (suggestions.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text('اقتراحات',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...suggestions.map(_buildUserTile),
                  ],
                ],
              ),
            ),
          ),

          // نسخ الرابط + مشاركة تطبيقات خارجية
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // زر نسخ الرابط بتدرج
                Expanded(
                  child: Container(
                    width: 25,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: _copyLink,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.copy, color: Colors.white),
                            SizedBox(width: 6),
                            Text('نسخ الرابط',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // زر مشاركة التطبيقات بتدرج
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () => Share.share(widget.postImageUrl),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.share, color: Colors.white),
                            SizedBox(width: 6),
                            Text('تطبيقات أخرى',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final uid = user['uid'] as String;
    final isSent = sentUserIds.contains(uid);
    final img = user['profileImage'] as String?;

    const gradient = LinearGradient(
      colors: [ Color(0xFF4423B1),
            Color(0xFF6B2298),],
      begin: Alignment.centerLeft,
          end: Alignment.centerRight,
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (img != null && img.isNotEmpty)
            ? NetworkImage(img)
            : AssetImage('assets/images/2.png') as ImageProvider,
      ),
      title: Text(user['storeName'] ?? 'مستخدم'),
      trailing: Container(
        decoration: BoxDecoration(
          gradient: isSent ? null : gradient,
          color: isSent ? Colors.grey : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: isSent ? null : () => _sendToUser(uid),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              isSent ? 'تم' : 'إرسال',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
