import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:video_player/video_player.dart';

class RegionPostsScreen extends StatefulWidget {
  final String? region;
  final String? locationUrl;
  final bool showAll;

  const RegionPostsScreen({
    super.key,
    this.region,
    this.locationUrl,
    this.showAll = false,
  });

  @override
  State<RegionPostsScreen> createState() => _RegionPostsScreenState();
}

class _RegionPostsScreenState extends State<RegionPostsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<String> workTypes = [
    'الكل',
    'كيك',
    'خياطة',
    'الكوافير',
    'أعمال أخرى',
    'الأعلى تقييماً'
  ];
  String selectedWorkType = 'الكل';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: workTypes.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        selectedWorkType = workTypes[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<QueryDocumentSnapshot>> getPostsStream(String workType) async* {
    if (workType == 'الأعلى تقييماً') {
      Query userQuery = FirebaseFirestore.instance.collection('users');
      if (!widget.showAll) {
        if (widget.region != null) {
          userQuery = userQuery.where('location', isEqualTo: widget.region);
        } else if (widget.locationUrl != null) {
          userQuery =
              userQuery.where('locationUrl', isEqualTo: widget.locationUrl);
        }
      }

      final userSnapshot = await userQuery.get();
      final users = userSnapshot.docs;
      final List<Map<String, dynamic>> usersWithRatings = [];

      for (var user in users) {
        final ratingSnap = await FirebaseFirestore.instance
            .collection('storeRatings')
            .doc(user.id)
            .get();
        final rating = ratingSnap.data()?['averageRating'] ?? 0.0;
        usersWithRatings.add({'uid': user.id, 'rating': rating});
      }

      usersWithRatings.sort((a, b) => (b['rating']).compareTo(a['rating']));

      List<QueryDocumentSnapshot> topPosts = [];
      for (var u in usersWithRatings) {
        final postSnap = await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: u['uid'])
            .limit(1)
            .get();
        if (postSnap.docs.isNotEmpty) {
          topPosts.add(postSnap.docs.first);
        }
      }

      yield topPosts;
    } else {
      Query baseQuery = FirebaseFirestore.instance.collection('posts');

      if (!widget.showAll) {
        if (widget.region != null) {
          baseQuery = baseQuery.where('location', isEqualTo: widget.region);
        } else if (widget.locationUrl != null) {
          baseQuery =
              baseQuery.where('locationUrl', isEqualTo: widget.locationUrl);
        }
      }

      if (workType != 'الكل') {
        baseQuery = baseQuery.where('workType', isEqualTo: workType);
      }

      yield* baseQuery.snapshots().map((snap) => snap.docs);
    }
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    final userSnap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userSnap.data() ?? {};
  }

  void navigateToStorePage(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(userId: uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
            ),
          ),
        ),
        title: Center(
          child: Text(
            'متاجر ${widget.region ?? ""}',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: screenWidth < 600 ? 18 : 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.all(screenWidth * 0.03),
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.deepPurple),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {
                      searchQuery = value.trim();
                    }),
                    decoration: InputDecoration(
                      hintText: 'بحث',
                      hintStyle: TextStyle(fontFamily: 'Tajawal',fontSize:screenWidth < 600 ? 14 : 16 ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: Colors.deepPurple),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: workTypes.length,
              itemBuilder: (context, index) {
                final type = workTypes[index];
                final isSelected = selectedWorkType == type;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedWorkType = type;
                      _tabController.index = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Colors.deepPurple : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: screenWidth < 600 ? 16 : 18,
                          color: Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: getPostsStream(selectedWorkType),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final posts = snapshot.data!;
                final filteredPosts = posts.where((post) {
                  final data = post.data() as Map<String, dynamic>;
                  final storeName = data['storeName']?.toString() ?? '';
                  final type = data['workType']?.toString() ?? '';
                  return storeName.contains(searchQuery) ||
                      type.contains(searchQuery);
                }).toList();

                if (filteredPosts.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد منشورات مطابقة.',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: screenWidth < 600 ? 14 : 16,
                      ),
                    ),
                  );
                }

                return MasonryGridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    final data = post.data() as Map<String, dynamic>;
                    final postUrl = data['postUrl'] ?? '';
                    final uid = data['uid'] ?? '';
                    final isVideo = data['isVideo'] ?? false;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: getUserData(uid),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox.shrink();
                        }
                        if (!userSnapshot.hasData ||
                            userSnapshot.data == null) {
                          return SizedBox.shrink();
                        }

                        final user = userSnapshot.data!;
                        final username = user['storeName'] ?? 'بدون اسم';
                        final userPhoto = user['profileImage'] ?? '';

                        return GestureDetector(
                          onTap: () => navigateToStorePage(uid),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: isVideo
                                      ? PostVideoPlayer(videoUrl: postUrl)
                                      : Image.network(
                                          postUrl,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => navigateToStorePage(uid),
                                        child: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(userPhoto),
                                          radius: screenWidth * 0.04,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              navigateToStorePage(uid),
                                          child: Text(
                                            username,
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: screenWidth < 600 ? 12 : 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const PostVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _PostVideoPlayerState createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: VideoPlayer(_controller),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}