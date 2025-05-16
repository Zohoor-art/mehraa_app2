import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mehra_app/modules/site/region_stores_screen.dart';

class AutoLocationButton extends StatelessWidget {
  const AutoLocationButton({super.key});

  Future<void> _handleLocation(BuildContext context) async {
    // طلب الإذن بالموقع
    var status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب السماح بالوصول للموقع لاستخدام هذه الميزة')),
      );
      return;
    }

    try {
      // جلب الإحداثيات
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // تحويل الإحداثيات إلى عنوان
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception("تعذر تحديد الموقع.");
      }

      Placemark place = placemarks.first;
      String area = place.subLocality?.isNotEmpty == true
          ? place.subLocality!
          : place.locality ?? 'منطقة غير معروفة';

      // تأكيد من المستخدم
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("تحديد الموقع"),
          content: Text("تم تحديد موقعك في: $area\nهل تريد عرض المتاجر القريبة؟"),
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
            builder: (_) => RegionPostsScreen(region: area),
          ),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحديد الموقع: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleLocation(context),
      icon: const Icon(Icons.my_location),
      label: const Text("تحديد الموقع تلقائيًا"),
    );
  }
}
