import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/modules/profile/editProfile.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/modules/rating/add_rating.dart';
import 'package:mehra_app/modules/rating/rating.dart';
import 'package:mehra_app/modules/tabs/feed_view.dart';
import 'package:mehra_app/modules/tabs/reels_view.dart';
import 'package:mehra_app/modules/tabs/tagged_view.dart';
import 'package:mehra_app/shared/components/custom_Dialog.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Users? currentUser;
  double averageRating = 0;
  bool isLoading = true;
  int followersCount = 0;
  int followingCount = 0;

  late List<Widget> tabBarViews;

  final List<Widget> tabs = const [
    Tab(icon: Icon(Icons.image)),
    Tab(icon: Icon(Icons.video_collection)),
    Tab(icon: Icon(Icons.person_2_sharp)),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchFollowersAndFollowingCount();
    fetchRating();
  }

  Future<void> fetchRating() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('storeRatings')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          averageRating = (snapshot['averageRating'] ?? 0) / 25;
        });
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }
  }

  Future<void> fetchUserData() async {
    final snap = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    if (snap.exists) {
      final user = Users.fromSnap(snap);

      setState(() {
        currentUser = user;
        final isCurrentUser = widget.userId == FirebaseAuth.instance.currentUser?.uid;

        tabBarViews = [
          FeedView(userId: widget.userId),
          UserVideosView(userId: widget.userId),
          TaggedView(isCurrentUser: isCurrentUser),
        ];

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFollowersAndFollowingCount() async {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: screenWidth * 0.01,
          ),
        ),
      );
    }

    bool isStoreOwner = currentUser?.storeName.isNotEmpty ?? false;

    return isStoreOwner
        ? buildStoreProfile(context, screenWidth, screenHeight)
        : buildGoogleUserProfile(context, screenWidth, screenHeight);
  }

  Widget buildStoreProfile(BuildContext context, double screenWidth, double screenHeight) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: screenHeight * 0.07,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [MyColor.blueColor, MyColor.purpleColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: Text(
            currentUser!.storeName, 
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
            ),
          ),
          actions: widget.userId == FirebaseAuth.instance.currentUser!.uid
              ? [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white, size: screenWidth * 0.06),
                    tooltip: 'تعديل الملف الشخصي',
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            currentData: {
                              'storeName': currentUser!.storeName,
                              'description': currentUser!.description,
                              'location': currentUser!.location,
                              'profileImage': currentUser!.profileImage,
                            },
                            userId: widget.userId,
                            user: currentUser!,
                          ),
                        ),
                      );

                      if (updated == true) {
                        fetchUserData();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white, size: screenWidth * 0.06),
                    tooltip: 'مشاركة الملف الشخصي',
                    onPressed: () {},
                  ),
                ]
              : null,
        ),
        body: ListView(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$followingCount', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: screenWidth * 0.045
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      'متابع', 
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: screenWidth * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipOval(
                        child: Image.network(
                          currentUser!.profileImage ?? '',
                          height: screenWidth * 0.25,
                          width: screenWidth * 0.25,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (widget.userId == FirebaseAuth.instance.currentUser!.uid)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final confirm = await CustomDialog.show<bool>(
                                context,
                                title: 'تعديل صورة الملف الشخصي',
                                content: 'هل تريد تعديل صورة الملف الشخصي؟',
                                icon: Icons.edit,
                                confirmText: 'نعم',
                                cancelText: 'لا',
                                onConfirm: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      currentData: {
                                        'storeName': currentUser!.storeName,
                                        'description': currentUser!.description,
                                        'location': currentUser!.location,
                                        'profileImage': currentUser!.profileImage,
                                      },
                                      userId: widget.userId,
                                      user: currentUser!,
                                    ),
                                  ),
                                ),
                                onCancel: () => Navigator.pop(context, false),
                              );

                              if (confirm == true) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      currentData: {
                                        'storeName': currentUser!.storeName,
                                        'description': currentUser!.description,
                                        'location': currentUser!.location,
                                        'profileImage': currentUser!.profileImage,
                                      },
                                      userId: widget.userId,
                                      user: currentUser!,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.015),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                size: screenWidth * 0.045,
                                color: MyColor.darkPurpleColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.05),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$followersCount', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: screenWidth * 0.045
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      'متابعين', 
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentUser!.storeName, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                Text(' | ', style: TextStyle(fontSize: screenWidth * 0.04)),
                Text(
                  currentUser!.workType, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Text(
                currentUser!.description,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: screenWidth * 0.038),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Column(
              children: [
                Text(
                  currentUser!.location, 
                  style: TextStyle(
                    color: Colors.blue, 
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  currentUser!.email, 
                  style: TextStyle(
                    color: Colors.blue, 
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'التقييم', 
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      ...List.generate(5, (index) => Icon(
                        index < averageRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: screenWidth * 0.05,
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      GradientButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RatingsListPage(userId: widget.userId))),
                        text: 'تفاصيل',
                        width: screenWidth * 0.18,
                        height: screenHeight * 0.04,
                        fontSize: screenWidth * 0.03,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      GradientButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RatingCard(uid: widget.userId))),
                        text: 'تقييم',
                        width: screenWidth * 0.18,
                        height: screenHeight * 0.04,
                        fontSize: screenWidth * 0.03,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TabBar(tabs: tabs),
            SizedBox(
              height: screenHeight * 0.6,
              child: TabBarView(
                children: tabBarViews,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoogleUserProfile(BuildContext context, double screenWidth, double screenHeight) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser?.email ?? "بلا بريد",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          CircleAvatar(
            backgroundImage: NetworkImage(currentUser!.profileImage ?? ''),
            radius: screenWidth * 0.15,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            currentUser!.email, 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.04,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'يتابع: $followingCount',
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
          Text(
            'المتابعين: $followersCount',
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ],
      ),
    );
  }
}