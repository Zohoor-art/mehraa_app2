import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mehra_app/modules/tabs/tagged_view.dart'; // تأكد من المسار
import 'package:mehra_app/shared/appbar.dart';
import 'package:mehra_app/shared/components/constants.dart';

class GoogleUserProfile extends StatelessWidget {
  const GoogleUserProfile({super.key});

  Future<void> _signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<int> _getFollowersCount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('followers')
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: CustomGradientAppBar(
        title: Text('الملف الشخصي'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InkWell(
              onTap: () => _signOut(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout, size: 24),
                  SizedBox(height: 2),
                  Text(
                    'تسجيل الخروج',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("لم يتم تسجيل الدخول"))
          : FutureBuilder<int>(
              future: _getFollowersCount(user.uid),
              builder: (context, snapshot) {
                final followersCount =
                    snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData
                        ? snapshot.data!
                        : 0;

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                NetworkImage(user.photoURL ?? ''),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.displayName ?? 'اسم غير معروف',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text("$followersCount",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const Text("المتابَعين",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [MyColor.blueColor, MyColor.purpleColor],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                "ترقية إلى حساب تجاري",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // هذا هو الجزء المحدث: عرض المنشورات المحفوظة باستخدام TaggedView
                    Expanded(
                      child: DefaultTabController(
                        length: 1,
                        child: Column(
                          children: [
                            const TabBar(
                              labelColor: Colors.black,
                              indicatorColor: Colors.deepPurple,
                              tabs: [
                                Tab(text: "المنشورات المحفوظة"),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // هنا نستخدم Widget المنشورات المحفوظة مع الوظائف نفسها
                                  TaggedView(isCurrentUser: true),
                                ],
                              ),
                            ),
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
}
