import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/notifications/notification_methods.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:mehra_app/shared/components/custom_Dialog.dart';

class RatingCard extends StatefulWidget {
  final String uid;

  const RatingCard({Key? key, required this.uid}) : super(key: key);

  @override
  _RatingCardState createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  List<List<bool>> starRatings = [
    [false, false, false, false],
    [false, false, false, false],
    [false, false, false, false],
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
        const SnackBar(content: Text('يرجى تقييم جميع الفئات قبل الحفظ ❗')),
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

      final storeDocRef = FirebaseFirestore.instance.collection('storeRatings').doc(widget.uid);
      final storeSnapshot = await storeDocRef.get();

      int totalRatings = 1;
      double totalAverageRating = averageRating.toDouble();

      if (storeSnapshot.exists) {
        final data = storeSnapshot.data()!;
        totalRatings = (data['totalRatings'] ?? 0) + 1;
        final prevAvg = (data['averageRating'] ?? 0).toDouble();
        totalAverageRating = ((prevAvg * (totalRatings - 1)) + averageRating) / totalRatings;
      }

      await storeDocRef.set({
        'averageRating': totalAverageRating,
        'totalRatings': totalRatings,
        'lastRatingTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await NotificationMethods.sendRatingNotification(
        toUid: widget.uid,
        fromUid: currentUserUid,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ تقييمك بنجاح ✅')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('خطأ أثناء حفظ التقييم: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الحفظ ❌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.05,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: screenWidth * 0.045,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: bottomImage()),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.08),
                      child: Container(
                        width: screenWidth * 0.9,
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.8,
                          minHeight: screenHeight * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: MyColor.LightSearchColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientButton(
                              height: screenHeight * 0.12,
                              width: screenWidth * 0.9,
                              onPressed: () {},
                              text: 'تذكر  أن \nقطع الرقاب ولاقطع الارزاق \nلذا راع الله في تقييمك',
                              fontSize: isSmallScreen ? screenWidth * 0.035 : screenWidth * 0.03,
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                                child: Text(
                                  'تقييم حسب',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? screenWidth * 0.045 : screenWidth * 0.04,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildRatingRow('جودة المنتج', 0, context),
                                  SizedBox(height: screenHeight * 0.015),
                                  buildRatingRow('أسلوب التعامل', 1, context),
                                  SizedBox(height: screenHeight * 0.015),
                                  buildRatingRow('الالتزام بالمواعيد', 2, context),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GradientButton(
                                    height: screenHeight * 0.06,
                                    width: screenWidth * 0.7,
                                    onPressed: () => _showConfirmationDialog(context),
                                    text: 'تأكيد',
                                    fontSize: screenWidth * 0.035,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  GradientButton(
                                    height: screenHeight * 0.06,
                                    width: screenWidth * 0.7,
                                    onPressed: () => _showCancelDialog(context),
                                    text: 'تراجع',
                                    fontSize: screenWidth * 0.035,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
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
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    CustomDialog.show(
      context,
      title: 'تأكيد التقييم',
      content: 'هل أنت متأكد أنك تريد حفظ هذا التقييم؟',
      confirmText: 'نعم',
      cancelText: 'لا',
      icon: Icons.check_circle,
      iconColor: Colors.white,
      confirmButtonColor: Colors.green,
      onConfirm: submitRatings,
      onCancel: () => Navigator.pop(context),
    );
  }

  void _showCancelDialog(BuildContext context) {
    CustomDialog.show(
      context,
      title: 'تراجع عن التقييم',
      content: 'ماذا تريد أن تفعل؟',
      confirmText: 'تراجع عن التقييم',
      cancelText: 'خروج',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.white,
      confirmButtonColor: Colors.orange,
      onConfirm: () {
        Navigator.pop(context);
        setState(() {
          starRatings = [
            [false, false, false, false],
            [false, false, false, false],
            [false, false, false, false],
          ];
        });
      },
      onCancel: () {
        Navigator.pop(context);
        Navigator.of(context).pop();
      },
    );
  }

  Widget buildRatingRow(String label, int rowIndex, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? screenWidth * 0.035 : screenWidth * 0.03,
          ),
        ),
        Row(
          children: List.generate(4, (colIndex) {
            return GestureDetector(
              onTap: () => toggleStar(rowIndex, colIndex),
              child: Icon(
                Icons.star,
                size: isSmallScreen ? screenWidth * 0.06 : screenWidth * 0.05,
                color: starRatings[rowIndex][colIndex] ? Colors.yellow : const Color(0xFFC4BCBC),
              ),
            );
          }),
        ),
      ],
    );
  }
}