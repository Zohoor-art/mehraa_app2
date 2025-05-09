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
import 'package:mehra_app/modules/homePage/post.dart';
import 'package:mehra_app/modules/homePage/story_page.dart';
import 'package:mehra_app/modules/login/login_screen.dart';
import 'package:mehra_app/modules/notifications/Notification.dart';

import 'package:mehra_app/modules/site/nearToUPage.dart';

import 'package:mehra_app/modules/settings/PrivacySettingsPage.dart';
import 'package:mehra_app/modules/settings/Settings.dart';

import 'package:mehra_app/modules/site/site.dart';
import 'package:mehra_app/modules/xplore/xplore_screen.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';
import 'package:mehra_app/shared/components/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;
  final Firebase_Firestor _firebaseFirestor = Firebase_Firestor();

  @override
  void initState() {
    super.initState();
    StoryCleaner.cleanExpiredStories();
  }

  final List<Widget> _pages = [
    const NearbyOptionsScreen(),
    const XploreScreen(),
    const HomePage(),
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
            (icon as Icon).icon,
            color: _currentIndex == _navigationItems.indexOf(icon)
                ? Colors.white
                : MyColor.blueColor,
          );
        }).toList(),
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
Row(
  children: [
    // Profile icon
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
      ),
    ),
    const SizedBox(width: 8),

    // Popup Menu for settings and logout
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
                  Navigator.pop(context);
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.scale,
                    title: 'تأكيد الخروج',
                    desc: 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Notifications()),
        );
      },
      child: const Icon(FontAwesomeIcons.bell, size: 25),
    ),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPostscreen()),
        );
      },
      child: const Icon(Icons.add_circle_outline_outlined, size: 25),
    ),
  ],
),

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

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('تم حذف المنشور بنجاح')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'حدث خطأ أثناء الحذف: $e')),

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

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'تم استعادة المنشور بنجاح')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'حدث خطأ أثناء الاستعادة: $e')),

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

                                  SnackBar(
                                      content:
                                          Text('حدث خطأ أثناء تحديث الإعجاب')),

                                );
                              }
                            },
                            onSave: () async {
                              try {

                                final uid =
                                    FirebaseAuth.instance.currentUser?.uid;

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

                                  SnackBar(
                                      content: Text('حدث خطأ أثناء الحفظ')),
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
        ))

      ]),
    );
  }
}
