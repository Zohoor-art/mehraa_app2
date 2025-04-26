import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/xplore/ImageViewer.dart';
import 'package:mehra_app/modules/xplore/VideoPlayer.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:video_player/video_player.dart'; // مكتبة تشغيل الفيديو

class XploreScreen extends StatelessWidget {
  const XploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FF),
      appBar: AppBar(
        toolbarHeight: 3,
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
      body: XploreBody(),
    );
  }
}

class XploreBody extends StatefulWidget {
  @override
  _XploreBodyState createState() => _XploreBodyState();
}

class _XploreBodyState extends State<XploreBody> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  bool isLoading = false;

  void _searchPosts(String query) async {
    setState(() {
      isLoading = true;
    });

    final result = await FirebaseFirestore.instance.collection('posts').get();

    final filtered = result.docs
        .map((doc) => doc.data())
        .where((data) {
          final description = (data['description'] ?? '').toString().toLowerCase();
          final storeName = (data['storeName'] ?? '').toString().toLowerCase();
          return description.contains(query.toLowerCase()) || storeName.contains(query.toLowerCase());
        })
        .toList();

    setState(() {
      _searchResults = filtered;
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _getAllPosts() async {
    final result = await FirebaseFirestore.instance.collection('posts').get();
    return result.docs.map((doc) => doc.data()).toList();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _searchController.text.isEmpty
                        ? _getAllPosts()
                        : Future.value(_searchResults),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final posts = snapshot.data!;
                      if (posts.isEmpty) {
                        return const Center(child: Text('لا يوجد نتائج'));
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2.0,
                          mainAxisSpacing: 2.0,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final postUrl = post['postUrl'] ?? '';
                          final isVideo = postUrl.toLowerCase().endsWith('.mp4') || postUrl.toLowerCase().endsWith('.mov');

                          return GestureDetector(
                            onTap: () {
                              if (isVideo) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPlayerScreen(videoUrl: postUrl),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImageViewerScreen(imageUrl: postUrl),
                                  ),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isVideo
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        image: const DecorationImage(
                                          image: AssetImage('assets/video_placeholder.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      postUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        );
                                      },
                                    ),
                            ),
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

  Widget _buildSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 55,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 0),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(Icons.search, color: MyColor.blueColor),
              onPressed: () {
                _searchPosts(_searchController.text.trim());
              },
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: TextField(
                focusNode: _focusNode,
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'بحث عن وصف أو اسم متجر',
                  border: InputBorder.none,
                ),
                onSubmitted: _searchPosts,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.notifications_outlined,
              size: 22,
              color: MyColor.blueColor,
            ),
          ),
        ],
      ),
    );
  }
}
