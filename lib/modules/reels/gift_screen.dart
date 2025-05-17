import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/shared/components/constants.dart';

class GiftsScreen extends StatefulWidget {
  final String postId;
  final String receiverId;
  final String receiverName;

  const GiftsScreen({
    Key? key,
    required this.postId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _GiftsScreenState createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSending = false;
  int? _selectedGiftIndex;

  final List<Gift> _availableGifts = [
    Gift(
      id: '1',
      name: 'قلب',
      icon: Icons.favorite,
      price: 10,
      color: MyColor.pinkColor,
    ),
    Gift(
      id: '2',
      name: 'نجمة',
      icon: Icons.star,
      price: 20,
      color: MyColor.purpleColor,
    ),
    Gift(
      id: '3',
      name: 'تاج',
      icon: Icons.workspace_premium,
      price: 50,
      color: MyColor.purpleColor,
    ),
    Gift(
      id: '4',
      name: 'كرة',
      icon: Icons.sports_soccer,
      price: 30,
      color: MyColor.blueColor,
    ),
    Gift(
      id: '5',
      name: 'هدية',
      icon: Icons.card_giftcard,
      price: 40,
      color: MyColor.pinkColor,
    ),
    Gift(
      id: '6',
      name: 'الماس',
      icon: Icons.diamond,
      price: 100,
      color: MyColor.blueColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final isPortrait = screenSize.height > screenSize.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'إرسال هدية لـ ${widget.receiverName}',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: MyColor.purpleColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // شبكة الهدايا
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isPortrait ? 2 : 3,
                    crossAxisSpacing: isSmallScreen ? 10 : 15,
                    mainAxisSpacing: isSmallScreen ? 10 : 15,
                    childAspectRatio: isPortrait ? 0.9 : 1.2,
                  ),
                  itemCount: _availableGifts.length,
                  itemBuilder: (context, index) {
                    return _buildGiftItem(_availableGifts[index], index, screenSize);
                  },
                ),
              ),
            ),

            // زر الإرسال
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: SizedBox(
                width: double.infinity,
                height: screenSize.height * 0.07,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.pinkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedGiftIndex != null
                      ? () => _sendGift(_availableGifts[_selectedGiftIndex!])
                      : null,
                  child: _isSending
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'إرسال الهدية',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftItem(Gift gift, int index, Size screenSize) {
    final isSelected = _selectedGiftIndex == index;
    final isSmallScreen = screenSize.width < 400;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGiftIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          border: isSelected
              ? Border.all(color: MyColor.pinkColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة الهدية
            Container(
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                color: gift.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                gift.icon, 
                size: isSmallScreen ? 25 : 30, 
                color: gift.color,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 10),
            Text(
              gift.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on, 
                  size: isSmallScreen ? 14 : 16, 
                  color: Colors.amber,
                ),
                SizedBox(width: 4),
                Text(
                  '${gift.price}',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendGift(Gift gift) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    setState(() => _isSending = true);

    try {
      await _firestore.collection('gifts').add({
        'senderId': currentUser.uid,
        'receiverId': widget.receiverId,
        'postId': widget.postId,
        'giftId': gift.id,
        'giftName': gift.name,
        'value': gift.price,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(widget.receiverId).update({
        'totalGifts': FieldValue.increment(1),
        'giftsValue': FieldValue.increment(gift.price),
      });

      if (widget.receiverId != currentUser.uid) {
        await _firestore
            .collection('notifications')
            .doc(widget.receiverId)
            .collection('userNotifications')
            .add({
          'type': 'gift',
          'fromUserId': currentUser.uid,
          'postId': widget.postId,
          'giftName': gift.name,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال ${gift.name} بنجاح!'),
          backgroundColor: MyColor.pinkColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال الهدية: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }
}

class Gift {
  final String id;
  final String name;
  final IconData icon;
  final int price;
  final Color color;

  Gift({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    required this.color,
  });
}