import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class RatingCard extends StatefulWidget {
  @override
  _RatingCardState createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  // تخزين حالة النجوم لكل صف تقييم
  List<List<bool>> starRatings = [
    [false, false, false, false], // جودة المنتج
    [false, false, false, false], // أسلوب التعامل
    [false, false, false, false], // الالتزام بالمواعيد
  ];

  void toggleStar(int rowIndex, int colIndex) {
    setState(() {
      starRatings[rowIndex][colIndex] = !starRatings[rowIndex][colIndex]; // تغيير حالة النجمة عند النقر
    });
  }

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
      body: Stack(
        children: [
          Positioned.fill(
            child: bottomImage(), // الصورة في الخلفية
          ),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20), // المسافة بين الكونتينر والصورة
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: BoxDecoration(
                        color: MyColor.LightSearchColor,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 0),
                            blurRadius: 8,
                            spreadRadius: 7,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0.0),
                            child: GradientButton(
                              height: 150,
                              width: MediaQuery.of(context).size.width * 0.85,
                              onPressed: () {
                                // وظيفة الزر
                              },
                              text: 'تذكر  أن \nقطع الرقاب ولاقطع الارزاق \nلذا راع الله في تقييمك'
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'تقييم حسب',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRatingRow('جودة المنتج', 0),
                                const SizedBox(height: 20),
                                buildRatingRow('أسلوب التعامل', 1),
                                const SizedBox(height: 20),
                                buildRatingRow('الالتزام بالمواعيد', 2),
                              ],
                            ),
                          ),
                          SizedBox(height: 35),
                          Center(
                            child: Column(
                              children: [
                                GradientButton(
                                  height: 46,
                                  width: 285,
                                  onPressed: () {},
                                  text: 'تاكيد',
                                ),
                                const SizedBox(height: 25),
                                GradientButton(
                                  height: 46,
                                  width: 285,
                                  onPressed: () {},
                                  text: 'تراجع',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء صف التقييم
  Row buildRatingRow(String label, int rowIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 22)),
        Row(
          children: List.generate(4, (colIndex) {
            return GestureDetector(
              onTap: () => toggleStar(rowIndex, colIndex),
              child: Icon(
                Icons.star,
                size: 30,
                color: starRatings[rowIndex][colIndex] ? Colors.yellow : Color(0xFFC4BCBC),
              ),
            );
          }),
        ),
      ],
    );
  }
}