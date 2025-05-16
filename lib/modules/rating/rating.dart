import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/notifications/notification_methods.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class RatingCard extends StatefulWidget {
  final String uid; // معرف المتجر اللي بنقيمه

  const RatingCard({Key? key, required this.uid}) : super(key: key);

  @override
  _RatingCardState createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  List<List<bool>> starRatings = [
    [false, false, false, false], // جودة المنتج
    [false, false, false, false], // أسلوب التعامل
    [false, false, false, false], // الالتزام بالمواعيد
  ];

  void toggleStar(int rowIndex, int colIndex) {
    setState(() {
      for (int i = 0; i <= 3; i++) {
        starRatings[rowIndex][i] = i <= colIndex;
      }
    });
  }

  bool isEveryCategoryRated() {
    for (var rating in starRatings) {
      if (rating.where((star) => star).isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<void> submitRatings() async {
    if (!isEveryCategoryRated()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تقييم جميع الفئات قبل الحفظ ❗')),
      );
      return;
    }

    try {
      int productQuality = starRatings[0].where((star) => star).length;
      int interactionStyle = starRatings[1].where((star) => star).length;
      int commitment = starRatings[2].where((star) => star).length;

      double averagePoints = (productQuality + interactionStyle + commitment) / 3;
      int averageRating = ((averagePoints / 4) * 100).round();

      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      // حفظ التقييم كمستند منفصل داخل collection فرعي "ratings"
      final ratingDocRef = await FirebaseFirestore.instance
          .collection('storeRatings')
          .doc(widget.uid)
          .collection('ratings')
          .add({
        'productQuality': productQuality,
        'interactionStyle': interactionStyle,
        'commitment': commitment,
        'averageRating': averageRating,
        'timestamp': FieldValue.serverTimestamp(),
        'raterUid': currentUserUid,
      });

      // تحديث المستند الرئيسي storeRatings/{uid} بحساب متوسط النقاط و عدد التقييمات
      final storeDocRef = FirebaseFirestore.instance.collection('storeRatings').doc(widget.uid);

      final storeSnapshot = await storeDocRef.get();

      int totalRatings = 1;
      double totalAverageRating = averageRating.toDouble();

      if (storeSnapshot.exists) {
        final data = storeSnapshot.data()!;
        totalRatings = (data['totalRatings'] ?? 0) + 1;
        final prevAvg = (data['averageRating'] ?? 0).toDouble();

        // تحديث المتوسط التراكمي
        totalAverageRating = ((prevAvg * (totalRatings - 1)) + averageRating) / totalRatings;
      }

      await storeDocRef.set({
        'averageRating': totalAverageRating,
        'totalRatings': totalRatings,
        'lastRatingTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // إرسال إشعار التقييم
      await NotificationMethods.sendRatingNotification(
        toUid: widget.uid,
        fromUid: currentUserUid,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ تقييمك بنجاح ✅')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('خطأ أثناء حفظ التقييم: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ ❌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
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
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: bottomImage(),
          ),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
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
                              onPressed: () {},
                              text: 'تذكر  أن \nقطع الرقاب ولاقطع الارزاق \nلذا راع الله في تقييمك',
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
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        title: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.green),
                                            SizedBox(width: 10),
                                            Text('تأكيد التقييم'),
                                          ],
                                        ),
                                        content: Text('هل أنت متأكد أنك تريد حفظ هذا التقييم؟'),
                                        actionsAlignment: MainAxisAlignment.spaceBetween,
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              submitRatings();
                                            },
                                            child: Text('نعم', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('لا', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  text: 'تأكيد',
                                ),
                                const SizedBox(height: 25),
                                GradientButton(
                                  height: 46,
                                  width: 285,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        title: Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                            SizedBox(width: 10),
                                            Text('تراجع عن التقييم'),
                                          ],
                                        ),
                                        content: Text('ماذا تريد أن تفعل؟'),
                                        actionsAlignment: MainAxisAlignment.spaceBetween,
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                starRatings = [
                                                  [false, false, false, false],
                                                  [false, false, false, false],
                                                  [false, false, false, false],
                                                ];
                                              });
                                            },
                                            child: Text('تراجع عن التقييم', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('خروج', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
