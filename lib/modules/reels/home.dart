// ignore_for_file: must_be_immutable

import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mehra_app/models/post.dart';
import 'package:mehra_app/modules/homePage/add_reels.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/modules/reels/reels.dart';

class HomeReels extends StatelessWidget {
    String? _videoPath;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      backgroundColor: MyColor.LightSearchColor,
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('posts')
                    .where('isVideo', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ في جلب البيانات'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('لا توجد فيديوهات متاحة'));
                  }

                  final videoPosts = snapshot.data!.docs
                      .map((doc) {
                        try {
                          return Post.fromSnap(doc);
                        } catch (e) {
                          return null;
                        }
                      })
                      .where((post) => post != null)
                      .cast<Post>()
                      .toList();

                  if (videoPosts.isEmpty) {
                    return Center(child: Text('لا توجد فيديوهات صالحة'));
                  }

                  return Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return ContentScreen(post: videoPosts[index]);
                    },
                    itemCount: videoPosts.length,
                    scrollDirection: Axis.vertical,
                  );
                },
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shoplets',
                      style: GoogleFonts.pacifico(color: MyColor.blueColor,fontSize: 30)
                    ),
                    IconButton(
                      icon: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Color(0xFF4423B1),
                              Color(0xFFA02D87),
                            ],
                          ).createShader(bounds);
                        },
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateReelScreen(videoPath: _videoPath!),
        ),);
                        // تنفيذ ما تريد هنا
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
