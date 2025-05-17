import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/firebase/firestore.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/modules/rating/add_rating.dart';
import 'package:mehra_app/modules/rating/rating.dart';

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
  double averageRating = 0;
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    _userFuture = _firestoreService.getUser(UID: widget.userId);
    _sharedImagesFuture = _getSharedImages();
    _fetchRating();
    _fetchFollowersAndFollowingCount();
  }

  Future<void> _fetchRating() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('storeRatings')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          averageRating = (snapshot['averageRating'] ?? 0) / 25; // Convert from 100 to 4 stars
        });
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }
  }

  Future<void> _fetchFollowersAndFollowingCount() async {
    final followersSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('followers')
        .get();

    final followingSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('following')
        .get();

    setState(() {
      followersCount = followersSnap.docs.length;
      followingCount = followingSnap.docs.length;
    });
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

  Widget _buildProfileHeader(Users user, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isCurrentUser = widget.userId == FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: isSmallScreen ? 120 : 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MyColor.blueColor, MyColor.purpleColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: isSmallScreen ? 100 : 120,
                height: isSmallScreen ? 100 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.profileImage ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/default_profile.png',
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/default_profile.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            if (isCurrentUser)
              Positioned(
                right: 20,
                bottom: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: IconButton(
                    icon: Icon(Icons.edit, size: 16, color: MyColor.purpleColor),
                    onPressed: () {
                      // Add edit profile functionality
                    },
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 10 : 20),
        Text(
          user.displayNameOrStoreName,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (user.workType.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: isSmallScreen ? 4 : 8),
            child: Text(
              user.workType,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        SizedBox(height: isSmallScreen ? 10 : 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatsColumn('المتابعون', followersCount),
            _buildStatsColumn('المتابعون', followingCount),
            _buildRatingSection(),
          ],
        ),
        SizedBox(height: isSmallScreen ? 10 : 20),
      ],
    );
  }

  Widget _buildStatsColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MyColor.purpleColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < averageRating.round() ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
        SizedBox(height: 4),
        Text(
          averageRating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(Users user) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.description.isNotEmpty) ...[
            Text(
              'الوصف',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              user.description,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 20),
          ],
          _buildInfoRow(Icons.email, user.email),
          if (user.contactNumber.isNotEmpty)
            _buildInfoRow(Icons.phone, user.contactNumber),
          if (user.location.isNotEmpty)
            _buildInfoRow(Icons.location_on, user.location),
          if (user.days.isNotEmpty || user.hours.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? 12 : 20),
            Text(
              'ساعات العمل',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            if (user.days.isNotEmpty)
              Text(
                'الأيام: ${user.days}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
            if (user.hours.isNotEmpty)
              Text(
                'الساعات: ${user.hours}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
          ],
          SizedBox(height: isSmallScreen ? 12 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RatingsListPage(userId: widget.userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: MyColor.purpleColor, backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: MyColor.purpleColor),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                    vertical: 8,
                  ),
                ),
                child: Text('التقييمات'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RatingCard(uid: widget.userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: MyColor.purpleColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                    vertical: 8,
                  ),
                ),
                child: Text('تقييم'),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: MyColor.purpleColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedImagesSection() {
    return FutureBuilder<List<String>>(
      future: _sharedImagesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }

        final images = snapshot.data!;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 24,
                vertical: isSmallScreen ? 8 : 16,
              ),
              child: Text(
                'الصور المتبادلة',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: isSmallScreen ? 4 : 8,
                crossAxisSpacing: isSmallScreen ? 4 : 8,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showFullImage(images[index]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isSmallScreen ? 12 : 20),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Users>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('حدث خطأ في تحميل البيانات'));
          }

          final user = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 40,
                pinned: true,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(bottom: 10),
                  title: Text(
                    'الملف الشخصي',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileHeader(user, context),
                  _buildProfileDetails(user),
                  _buildSharedImagesSection(),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}