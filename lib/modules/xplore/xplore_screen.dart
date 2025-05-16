import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/modules/profile/profile_screen.dart';

class XploreScreen extends StatelessWidget {
  const XploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FF),
      appBar: AppBar(toolbarHeight: 0),
      body: const XploreBody(),
    );
  }
}

class XploreBody extends StatefulWidget {
  const XploreBody({super.key});

  @override
  _XploreBodyState createState() => _XploreBodyState();
}

class _XploreBodyState extends State<XploreBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Users> _searchResults = [];
  bool isLoading = false;

  get otherUserId => null;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final lowerQuery = query.toLowerCase();
      final usersQuery = FirebaseFirestore.instance
          .collection('users')
          .where('storeNameLower', isGreaterThanOrEqualTo: lowerQuery)
          .where('storeNameLower', isLessThan: lowerQuery + 'z');

      final usersSnapshot = await usersQuery.get();

      final users =
          usersSnapshot.docs.map((doc) => Users.fromFirestore(doc)).toList();

      setState(() {
        _searchResults = users;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ خطأ في البحث: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 20),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(child: Text('ابدأ البحث عن متجر...'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.profileImage != null
                                ? NetworkImage(user.profileImage!)
                                : null,
                            backgroundColor: Colors.grey[300],
                          ),
                          title: Text(user.storeName),
                          subtitle: Text(user.workType),
                          onTap: () {
                             // ← هنا نجيبه
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(userId: otherUserId),
                              ),
                            );
                            //هنا اشتي يتم الانتقال الى صفحةProfileScreen
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          const Icon(Icons.search),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'ابحث عن متجر...',
                border: InputBorder.none,
              ),
              onChanged: _searchUsers, // ✅ شغّل البحث المباشر
            ),
          ),
        ],
      ),
    );
  }
}
