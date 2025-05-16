import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mehra_app/modules/site/locationSelection.dart';
import 'package:mehra_app/modules/site/region_stores_screen.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyOptionsScreen extends StatelessWidget {
  const NearbyOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'title': 'استكشاف حسب المنطقة',
        'icon': Icons.map,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const RegionSelectionScreen(showDetailedLocations: false),
            ),
          );
        },
      },
      {
        'title': 'البحث بالموقع المفصل',
        'icon': Icons.search,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const RegionSelectionScreen(showDetailedLocations: true),
            ),
          );
        },
      },
      {
        'title': 'تحديد الموقع تلقائيًا',
        'icon': Icons.gps_fixed,
        'onTap': () async {
          var status = await Permission.location.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('يجب السماح بالوصول للموقع لاستخدام هذه الميزة')),
            );
            return;
          }

          try {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text("جاري تحديد الموقع..."),
                  ],
                ),
              ),
            );

            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );

            List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );

            Navigator.pop(context);

            if (placemarks.isEmpty) {
              throw Exception("تعذر تحديد الموقع.");
            }

            Placemark place = placemarks.firstWhere(
              (p) =>
                  p.locality?.contains("Sana") == true ||
                  p.administrativeArea?.contains("Sana") == true,
              orElse: () => placemarks.first,
            );

            bool isInSanaa = place.locality?.contains("Sana") == true ||
                place.administrativeArea?.contains("Sana") == true;

            String area = place.subLocality?.isNotEmpty == true
                ? place.subLocality!
                : (place.thoroughfare?.isNotEmpty == true
                    ? place.thoroughfare!
                    : (place.locality ?? 'منطقة غير معروفة'));

            String regionToShow = isInSanaa ? area : 'شملان';

            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("تحديد الموقع"),
                content: Text("تم تحديد موقعك في: $regionToShow\nهل تريد عرض المتاجر القريبة؟"),
                actions: [
                  TextButton(
                    child: const Text("إلغاء"),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  ElevatedButton(
                    child: const Text("نعم"),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegionPostsScreen(region: regionToShow),
                ),
              );
            }
          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('حدث خطأ أثناء تحديد الموقع: $e')),
            );
          }
        }
      },
      {
        'title': 'دخول لاكتشاف الكل',
        'icon': Icons.explore,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegionPostsScreen(showAll: true),
            ),
          );
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'الأقرب إليك',
    style: TextStyle(fontSize: 20, color: Colors.black87),
  ),
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [MyColor.lightprimaryColor, MyColor.lightprimaryColor],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
  ),
  elevation: 0,
  backgroundColor: Colors.transparent,
),

backgroundColor: MyColor.lightprimaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
  padding: EdgeInsets.only(top: 16.0, bottom: 12.0),

  child: Center(
    child: Text(
      'اختر طريقة تحديد الموقع\nلتستكشف المتاجر القريبة منك',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.5,
        shadows: [
          Shadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
    ),
  ),
),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return InkWell(
                        onTap: option['onTap'] as VoidCallback,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    colors: [Colors.pinkAccent, Colors.deepPurple],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: Icon(
                                  option['icon'] as IconData,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                option['title'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
