import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mehra_app/models/firebase/firestore.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/SearchLocation/SearchLocation.dart';
import 'package:mehra_app/modules/Story/clear_story.dart';
import 'package:mehra_app/modules/chats/chats.dart';
import 'package:mehra_app/modules/homePage/add_postScreen.dart';
import 'package:mehra_app/modules/homePage/post.dart'; // تأكد من استيراد PostWidget
import 'package:mehra_app/modules/homePage/story_page.dart'; // تأكد من استيراد صفحة الاستوريات
import 'package:mehra_app/modules/login/login_screen.dart';
import 'package:mehra_app/modules/notifications/Notification.dart';
import 'package:mehra_app/modules/settings/PrivacySettingsPage.dart';
import 'package:mehra_app/modules/settings/Settings.dart';
import 'package:mehra_app/modules/site/site.dart';
import 'package:mehra_app/modules/xplore/xplore_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart'; // تأكد من استيراد صفحة البروفايل
import 'package:mehra_app/shared/components/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Default selected index
  final Firebase_Firestor _firebaseFirestor = Firebase_Firestor();
  @override
void initState() {
  super.initState();
  StoryCleaner.cleanExpiredStories();
}

  // List of pages corresponding to bottom navigation items
  final List<Widget> _pages = [
    const SiteScreen(),
    const SearchLocation(),
    const HomePage(), // Your Home page
    const XploreScreen(),
    const ChatsPage(),
  ];

  final List<Widget> _navigationItems = [
    const Icon(Icons.location_pin),
    const Icon(Icons.video_collection_sharp),
    const Icon(Icons.home),
    const Icon(Icons.search_sharp),
    const Icon(Icons.comment_rounded),
  ];

  Color bgColor = MyColor.lightprimaryColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      backgroundColor: MyColor.lightprimaryColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor: MyColor.blueColor,
        backgroundColor: bgColor,
        height: 60,
        index: _currentIndex,
        items: _navigationItems.map((icon) {
          return Icon(
            (icon as Icon).icon, // Cast to Icon to get the icon property
            color: _currentIndex == _navigationItems.indexOf(icon)
                ? Colors.white // Selected color
                : MyColor.blueColor, // Unselected color
          );
        }).toList(),
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update current index
          });
        },
      ),
    );
  }
}

// Separate widget for the home content
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: currentUserId),
      ),
    );
  }
},

                     child: FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircleAvatar(
        radius: 15,
        backgroundColor: Colors.grey,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
      return const CircleAvatar(
        radius: 15,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 15),
      );
    }

    final userData = snapshot.data!.data() as Map<String, dynamic>;
    final photoUrl = userData['profileImage'] as String?;

    return CircleAvatar(
      radius: 15,
      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
          ? NetworkImage(photoUrl)
          : null,
      child: (photoUrl == null || photoUrl.isEmpty)
          ? const Icon(Icons.person, size: 15)
          : null,
    );
  },
)

                    ),
const SizedBox(width: 8),
GestureDetector(
  onTapDown: (TapDownDetails details) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.lock, color: Colors.purple),
            title: Text('الخصوصية'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacySettingsPage()),
              );
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.settings, color: Colors.purple),
            title: Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.logout_sharp, size: 25, color: Colors.red),
            title: Text('تسجيل الخروج'),
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                animType: AnimType.scale,
                title: 'تأكيد الخروج',
                desc: 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                btnCancelOnPress: () {},
                btnOkOnPress: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  } catch (e) {
                    print("Error signing out: $e");
                    // يمكنك عرض SnackBar هنا في حال الخطأ
                  }
                },
              ).show();
            },
          ),
        ),
      ],
    );
  },
  child: const Icon(FontAwesomeIcons.bars, size: 25),
),
const SizedBox(width: 8),

                    GestureDetector(
                      onTap: () {
                        // Navigate to ChatsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Notifications()),
                        );
                      },
                      child: const Icon(FontAwesomeIcons.bell, size: 25),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Navigate to another page (مثلاً، الصفحة الخاصة بك)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddPostscreen()),
                        );
                      },
                      child: const Icon(Icons.add_circle_outline_outlined, size: 25),
                    ),
                    const SizedBox(width: 8),
                    ],
                ),
                Text(
                  'Mehra',
                  style: GoogleFonts.pacifico(fontSize: 30),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                height: 130, // Adjust height as needed for stories
                child:  StoryPage(), // هنا يتم عرض الاستوريات
              ),
              const SizedBox(height: 10), 
              const Divider(color: Color.fromARGB(255, 247, 237, 237)),
            ],
          ),
          // Main content area
        Expanded(
          child:StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('posts')
      .orderBy('datePublished', descending: true)
      .snapshots(includeMetadataChanges: true),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('جاري تحميل المنشورات...'),
          ],
        ),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red),
            SizedBox(height: 10),
            Text('حدث خطأ في تحميل البيانات', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(snapshot.error.toString(),
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // يمكنك ربطها بإعادة تحميل عبر Bloc أو Provider
              },
              child: Text('حاول مرة أخرى'),
            ),
          ],
        ),
      );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text('لا توجد منشورات متاحة حالياً', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    final isOffline = snapshot.data!.metadata.isFromCache;

    try {
    final posts = snapshot.data!.docs
    .map((doc) => Post.fromSnap(doc))
    .where((post) =>
        (post.postUrl.isNotEmpty || (post.isVideo && post.videoUrl.isNotEmpty)) &&
        post.isDeleted != true)
    .toList();


      return Column(
        children: [
          if (isOffline)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.amber[100],
              child: Row(
                children: [
                  Icon(Icons.cloud_off, size: 20),
                  SizedBox(width: 5),
                  Text('وضع عدم الاتصال - يتم عرض البيانات المحفوظة'),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final isCurrentUserPost =
                    post.uid == FirebaseAuth.instance.currentUser?.uid;
                    return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PostWidget(
                    key: ValueKey(post.postId),
                    post: post,
                    currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    onDelete: isCurrentUserPost
                        ? () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(post.postId)
                                  .update({
                                'isDeleted': true,
                                'deletedAt': Timestamp.now(),
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم حذف المنشور بنجاح')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')),

                              );
                            }
                          }
                        : null,
                    onRestore: isCurrentUserPost
                        ? () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(post.postId)
                                  .update({
                                'isDeleted': false,
                                'deletedAt': null,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم استعادة المنشور بنجاح')),

                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('حدث خطأ أثناء الاستعادة: $e')),
                              );
                            }
                          }
                        : null,
                    onLike: () async {
                      try {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) return;
                  

                        final postRef = FirebaseFirestore.instance
                            .collection('posts')
                            .doc(post.postId);

                        if (post.likes.contains(uid)) {
                          await postRef.update({
                            'likes': FieldValue.arrayRemove([uid]),
                          });
                        } else {
                          await postRef.update({
                            'likes': FieldValue.arrayUnion([uid]),
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('حدث خطأ أثناء تحديث الإعجاب')),

                        );
                      }
                    },
                    onSave: () async {
                      try {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) return;

                        final postRef = FirebaseFirestore.instance
                            .collection('posts')
                            .doc(post.postId);

                        if (post.savedBy.contains(uid)) {
                          await postRef.update({
                            'savedBy': FieldValue.arrayRemove([uid]),
                          });
                        } else {
                          await postRef.update({
                            'savedBy': FieldValue.arrayUnion([uid]),
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('حدث خطأ أثناء الحفظ')),

                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error processing posts: $e');
      return Center(
        child: Text('حدث خطأ في معالجة البيانات'),
      );
    }
  },
)

        )

     ] ),
    );
  }
}
