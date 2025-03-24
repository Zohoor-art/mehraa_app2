import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mehra_app/modules/SearchLocation/DetailsPage.dart';
import 'package:mehra_app/shared/components/constants.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key});

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  String? selectedCategory;

  final List<String> categories = [
    'الكل',
    'طبخ',
    'زهور',
    'خياطة',
    'كيك',
    // أضف المزيد من الفئات إذا لزم الأمر
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
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
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 15.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        size: 30, color: MyColor.purpleColor),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Text(
                  'الاكسبلور',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 12, 12, 12),
                    fontSize: 25,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 23.0),
                  child: Icon(
                    Icons.list,
                    size: 30,
                    color: MyColor.purpleColor,
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search_outlined,
                        size: 30, color: Color(0xFF6319A5)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'بحث',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Tajawal',
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.person_outlined,
                      color: Color(0xFF6319A5),
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              height: 35, // ارتفاع الحاوية
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
                            ? Color(0xFFCCB9E6) // اللون عند التحديد
                            : Color(0xFFDAD9DA), // اللون الافتراضي
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
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemCount: 50, // عدد العناصر التي تريد عرضها
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsPage(
                                  imageUrl:  'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}',
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsPage(
                                        imageUrl:
                                            'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}'),
                                  ),
                                );
                              },
                              child: FutureBuilder(
                                future: precacheImage(
                                  NetworkImage(
                                      'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}'), // استبدل هذا بالرابط الصحيح
                                  context,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Image.network(
                                      'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}', // استبدل هذا بالرابط الصحيح
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return AspectRatio(
                                      aspectRatio: (800 + index) /
                                          ((index % 2 + 1) * 970),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black,
                                              spreadRadius: 6,
                                              blurRadius: 6,
                                              offset: const Offset(5, 3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    ' روز للورود الطبيعية ',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.more_horiz,
                                  size: 30,
                                  color: MyColor.blueColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
