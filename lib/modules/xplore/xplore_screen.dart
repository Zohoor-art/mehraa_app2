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
          .where('storeNameLower', isLessThan: lowerQuery + 'z')
          .limit(20); // تحديد عدد النتائج

      final usersSnapshot = await usersQuery.get();

      final users = usersSnapshot.docs.map((doc) {
        final user = Users.fromFirestore(doc);
        return user;
      }).toList();

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12.0 : 20.0,
        vertical: 16.0,
      ),
      child: Column(
        children: [
          _buildSearchBar(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          'ابدأ البحث عن متجر...',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return _buildUserItem(user, isSmallScreen);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: isSmallScreen ? 22 : 24),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'ابحث عن متجر...',
                hintStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              onChanged: _searchUsers,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, size: isSmallScreen ? 18 : 20),
              onPressed: () {
                _searchController.clear();
                _searchUsers('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUserItem(Users user, bool isSmallScreen) {
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(userId: user.uid),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 24 : 28,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
                backgroundColor: Colors.white,
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.storeName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    Text(
                      user.workType,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                size: isSmallScreen ? 24 : 28,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}