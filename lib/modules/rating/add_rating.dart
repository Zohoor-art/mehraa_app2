import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/notifications/notification_methods.dart';
import 'package:mehra_app/modules/notifications/notifications_services.dart';
import 'package:mehra_app/shared/components/constants.dart';

class RatingsListPage extends StatefulWidget {
  final String userId;
  const RatingsListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _RatingsListPageState createState() => _RatingsListPageState();
}

class _RatingsListPageState extends State<RatingsListPage> {
  int productQuality = 0;
  int interactionStyle = 0;
  int commitment = 0;
  int totalRatings = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('storeRatings')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          productQuality = snapshot['productQuality'] ?? 0;
          interactionStyle = snapshot['interactionStyle'] ?? 0;
          commitment = snapshot['commitment'] ?? 0;
          totalRatings = snapshot['totalRatings'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching details: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildRatingIndicator(double percentage, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.5,
      child: LinearProgressIndicator(
        value: percentage / 100,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          _getProgressColor(percentage),
        ),
        minHeight: 10,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.lightGreen;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget buildStarsWithPercentage(int percentage, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double ratingOutOfFive = (percentage / 20);
    
    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              if (index < ratingOutOfFive.floor()) {
                return Icon(Icons.star, 
                  color: Colors.amber, 
                  size: screenWidth * 0.045
                );
              } else if (index < ratingOutOfFive) {
                return Icon(Icons.star_half, 
                  color: Colors.amber, 
                  size: screenWidth * 0.045
                );
              } else {
                return Icon(Icons.star_border, 
                  color: Colors.amber, 
                  size: screenWidth * 0.045
                );
              }
            }),
          ),
          SizedBox(height: 4),
          _buildRatingIndicator(percentage.toDouble(), context),
          SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: _getProgressColor(percentage.toDouble())
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailCard(String title, int value, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.015
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black12,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: MyColor.blueColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForTitle(title),
                color: MyColor.blueColor,
                size: screenWidth * 0.05,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800]
                ),
              ),
            ),
            buildStarsWithPercentage(value, context),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch(title) {
      case 'جودة المنتج': return Icons.assignment_turned_in;
      case 'أسلوب التعامل': return Icons.people_alt;
      case 'الالتزام بالمواعيد': return Icons.access_time;
      default: return Icons.star;
    }
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.15,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MyColor.blueColor, MyColor.purpleColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child:Row(
  children: [
    IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.pop(context); // للعودة للصفحة السابقة
      },
    ),
    SizedBox(width: screenWidth * 0.3,),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Text(
            'التقييم العام',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${((productQuality + interactionStyle + commitment) / 3).round()}%',
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  ],
)  ),
    );
  }

  Widget _buildRatingCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, color: Colors.grey, size: screenWidth * 0.05),
          SizedBox(width: 8),
          Text(
            'عدد المقيمين: $totalRatings',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
     body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: screenHeight * 0.03),
            buildDetailCard('جودة المنتج', productQuality, context),
            buildDetailCard('أسلوب التعامل', interactionStyle, context),
            buildDetailCard('الالتزام بالمواعيد', commitment, context),
            SizedBox(height: screenHeight * 0.03),
            _buildRatingCount(context),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  Future<void> submitRatingWithRaterInfo({
    required String storeId,
    required String raterUid,
    required String raterName,
    required int productQuality,
    required int interactionStyle,
    required int commitment,
  }) async {
    final storeRef = FirebaseFirestore.instance.collection('storeRatings').doc(storeId);
    final raterRef = storeRef.collection('raters').doc(raterUid);

    final ratingData = {
      'productQuality': productQuality,
      'interactionStyle': interactionStyle,
      'commitment': commitment,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': raterUid,
      'name': raterName,
    };

    try {
      await raterRef.set(ratingData);

      final snapshot = await storeRef.get();
      if (snapshot.exists) {
        final current = snapshot.data()!;
        int total = current['totalRatings'] ?? 0;
        int pq = current['productQuality'] ?? 0;
        int istyle = current['interactionStyle'] ?? 0;
        int com = current['commitment'] ?? 0;

        await storeRef.update({
          'totalRatings': total + 1,
          'productQuality': ((pq * total) + productQuality) ~/ (total + 1),
          'interactionStyle': ((istyle * total) + interactionStyle) ~/ (total + 1),
          'commitment': ((com * total) + commitment) ~/ (total + 1),
          'averageRating': (((pq * total) + productQuality + (istyle * total) + interactionStyle + (com * total) + commitment) ~/ (3 * (total + 1))),
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await storeRef.set({
          'totalRatings': 1,
          'productQuality': productQuality,
          'interactionStyle': interactionStyle,
          'commitment': commitment,
          'averageRating': ((productQuality + interactionStyle + commitment) ~/ 3),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      
      await NotificationMethods.sendRatingNotification(
        toUid: storeId,
        fromUid: raterUid,
      );

    } catch (e) {
      print('فشل في حفظ التقييم والمقيم: $e');
      throw e;
    }
  }
}