import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/modules/site/region_stores_screen.dart';

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
      print("🔍 Fetching regions using field: ${widget.showDetailedLocations ? 'locationUrl' : 'location'}");

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

      print("✅ Found regions: ${regionSet.length}");

      setState(() {
        regions = regionSet.toList();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching regions: $e");
      setState(() {
        regions = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.showDetailedLocations ? 'المواقع التفصيلية' : 'اختيار المنطقة')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : regions.isEmpty
              ? const Center(child: Text('لا توجد بيانات حالياً.'))
              : ListView.builder(
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    return ListTile(
                      title: Text(region, style: const TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegionPostsScreen(
                              region: widget.showDetailedLocations ? null : region,
                              locationUrl: widget.showDetailedLocations ? region : null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
