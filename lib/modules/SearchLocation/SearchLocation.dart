import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mehra_app/modules/SearchLocation/DetailsPage.dart';
import 'package:mehra_app/shared/components/constants.dart';

class RegionStoresGridScreen extends StatefulWidget {
  final String location;
  const RegionStoresGridScreen({super.key, required this.location});

  @override
  State<RegionStoresGridScreen> createState() => _RegionStoresGridScreenState();
}

class _RegionStoresGridScreenState extends State<RegionStoresGridScreen> {
  String selectedCategory = 'الكل';

  final List<String> categories = ['الكل', 'طبخ', 'زهور', 'خياطة', 'كيك'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
      appBar: AppBar(
        title: Text('المتاجر في ${widget.location}'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categories[index];
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: selectedCategory == categories[index]
                          ? Color(0xFFCCB9E6)
                          : Color(0xFFDAD9DA),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('location', isEqualTo: widget.location)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('لا توجد متاجر في هذه المنطقة.'));
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (selectedCategory == 'الكل') return true;
                  return data['type'] == selectedCategory;
                }).toList();

                return MasonryGridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final imageUrl = data['postUrl'] ?? 'https://via.placeholder.com/150';
                    final storeName = data['storeName'] ?? 'بدون اسم';

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsPage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 16),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(storeName, style: TextStyle(fontSize: 12)),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.more_horiz, size: 30, color: MyColor.blueColor),
                            ],
                          ),
                        ),
                      ],
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
