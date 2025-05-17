import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/modules/site/region_stores_screen.dart';
import 'package:mehra_app/shared/components/constants.dart';

class RegionSelectionScreen extends StatefulWidget {
  final bool showDetailedLocations;

  const RegionSelectionScreen({super.key, this.showDetailedLocations = false});

  @override
  State<RegionSelectionScreen> createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends State<RegionSelectionScreen> {
  List<String> regions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRegions();
  }

  Future<void> fetchRegions() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final regionSet = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (widget.showDetailedLocations) {
          final locationUrl = data['locationUrl'];
          if (locationUrl != null && locationUrl.toString().trim().isNotEmpty) {
            regionSet.add(locationUrl);
          }
        } else {
          final location = data['location'];
          if (location != null && location.toString().trim().isNotEmpty) {
            regionSet.add(location);
          }
        }
      }

      setState(() {
        regions = regionSet.toList()..sort();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        regions = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        toolbarHeight: isSmallScreen ? 60 : 70,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          widget.showDetailedLocations ? 'المواقع التفصيلية' : 'اختيار المنطقة',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: isSmallScreen ? 20 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
        ),
      ),),
      body: isLoading
          ?  Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyColor.purpleColor),
              ),
            )
          : regions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مناطق متاحة حالياً',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: isSmallScreen ? 18 : 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${regions.length} منطقة متاحة',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: regions.length,
                          itemBuilder: (context, index) {
                            final region = regions[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                elevation: 1,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RegionPostsScreen(
                                          region: widget.showDetailedLocations
                                              ? null
                                              : region,
                                          locationUrl: widget.showDetailedLocations
                                              ? region
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: MyColor.blueColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.location_on,
                                            color: MyColor.purpleColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            region,
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: isSmallScreen ? 16 : 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}