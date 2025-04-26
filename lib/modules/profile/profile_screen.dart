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

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Users? currentUser;
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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    bool isStoreOwner = currentUser?.storeName.isNotEmpty ?? false;

    return isStoreOwner
        ? buildStoreProfile(context)
        : buildGoogleUserProfile(context);
  }

  Widget buildStoreProfile(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [MyColor.blueColor, MyColor.purpleColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: Text(currentUser!.storeName, style: const TextStyle(color: Colors.white)),
          actions: widget.userId == FirebaseAuth.instance.currentUser!.uid
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
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
                        fetchUserData(); // إعادة تحميل البيانات بعد التحديث
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    tooltip: 'مشاركة الملف الشخصي',
                    onPressed: () {},
                  ),
                ]
              : null,
        ),
        body: ListView(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$followingCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 5),
                    Text('متابع', style: TextStyle(color: Colors.grey[800])),
                  ],
                ),
                const SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipOval(
                        child: Image.network(
                          currentUser!.profileImage ?? '',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (widget.userId == FirebaseAuth.instance.currentUser!.uid)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('تعديل صورة الملف الشخصي'),
                                  content: const Text('هل تريد تعديل صورة الملف الشخصي؟'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('لا'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('نعم'),
                                    ),
                                  ],
                                ),
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
                              padding: const EdgeInsets.all(6),
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
                              child: const Icon(Icons.edit, size: 18, color: Colors.blue),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$followersCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 5),
                    Text('متابعين', style: TextStyle(color: Colors.grey[800])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(currentUser!.storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text(' | '),
                Text(currentUser!.workType, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              alignment: Alignment.center,
              child: Text(
                currentUser!.description,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(currentUser!.location, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(currentUser!.email, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('التقييم', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 5),
                      ...List.generate(5, (index) => Icon(index < 4 ? Icons.star : Icons.star_border, color: Colors.amber)),
                    ],
                  ),
                  Row(
                    children: [
                      GradientButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RatingsListPage())),
                        text: 'تفاصيل', width: 70, height: 35, fontSize: 10,
                      ),
                      const SizedBox(width: 10),
                      GradientButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RatingCard())),
                        text: 'تقييم', width: 70, height: 35, fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TabBar(tabs: tabs),
            SizedBox(
              height: 1000,
              child: TabBarView(
                children: tabBarViews,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoogleUserProfile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser?.email ?? "بلا بريد",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            backgroundImage: NetworkImage(currentUser!.profileImage ?? ''),
            radius: 50,
          ),
          const SizedBox(height: 10),
          Text(currentUser!.email, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text('يتابع: $followingCount'),
          Text('المتابعين: $followersCount'),
        ],
      ),
    );
  }
}