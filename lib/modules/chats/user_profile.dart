import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/firebase/firestore.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/shared/components/constants.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final Firebase_Firestor _firestoreService = Firebase_Firestor();
  late Future<Users> _userFuture;
  late Future<List<String>> _sharedImagesFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _firestoreService.getUser(UID: widget.userId);
    _sharedImagesFuture = _getSharedImages();
  }

  Future<List<String>> _getSharedImages() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return [];
    final messages = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(widget.userId)
        .collection('messages')
        .where('imageUrl', isNotEqualTo: null)
        .get();
    return messages.docs.map((doc) => doc['imageUrl'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      backgroundColor: MyColor.lightprimaryColor,
      body: FutureBuilder<Users>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.blueGrey[900],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(user.displayNameOrStoreName),
                  background: Hero(
                    tag: 'profileImage_${user.uid}',
                    child: CachedNetworkImage(
                      imageUrl: user.profileImage ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Image.asset(
                          'assets/images/default_profile.png',
                          fit: BoxFit.cover),
                      errorWidget: (_, __, ___) => Image.asset(
                          'assets/images/default_profile.png',
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoTile(Icons.phone, user.contactNumber),
                      _infoTile(Icons.email, user.email),
                      _infoTile(Icons.location_on, user.location),
                      _communicationButtons(user.contactNumber, user.email),
                      SizedBox(height: 12),
                      _ratingSection(),
                      if (user.description.isNotEmpty)
                        _sectionText('الوصف', user.description),
                      // ignore: unnecessary_null_comparison
                      if (user.days != null || user.hours != null)
                        _sectionText(
                          'ساعات العمل',
                          'الأيام: ${user.days}\nالساعات: ${user.hours}',
                        ),
                      SizedBox(height: 16),
                      _buildImagesSection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [MyColor.purpleColor, MyColor.blueColor],
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _communicationButtons(String? phone, String? email) {
    return Row(
      // children: [
      //   if (phone != null)
      //     IconButton(
      //       icon: Icon(Icons.call, color: Colors.green),
      //       onPressed: () => launchUrl(Uri.parse("tel:\$phone")),
      //     ),
      //   if (email != null)
      //     IconButton(
      //       icon: Icon(Icons.email, color: Colors.red),
      //       onPressed: () => launchUrl(Uri.parse("mailto:\$email")),
      //     ),
      // ],
    );
  }

  Widget _sectionText(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              )),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _ratingSection() {
    double rating = 4.2; // مؤقتاً حتى توفر بيانات التقييم
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text("التقييم:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(width: 12),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber,
              );
            }),
          ),
          SizedBox(width: 8),
          Text(rating.toStringAsFixed(1),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return FutureBuilder<List<String>>(
      future: _sharedImagesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text("لا توجد صور متبادلة."),
          );
        }
        final images = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الصور المتبادلة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            GridView.builder(
              itemCount: images.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showFullImage(images[index]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (_, __, ___) => Icon(Icons.error),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
