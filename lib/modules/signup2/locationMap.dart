import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapSelectionScreen extends StatefulWidget {
  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  LatLng? currentLocation;
  LatLng? selectedLocation;
  String address = 'جارٍ تحديد العنوان...';
  bool fetchFailed = false;

  @override
  void initState() {
    super.initState();
    currentLocation = LatLng(15.3694, 44.1910); // صنعاء
    selectedLocation = currentLocation;
    _getAddressFromLatLng(selectedLocation!);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      selectedLocation = currentLocation;
    });
    _getAddressFromLatLng(selectedLocation!);
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${location.latitude}&lon=${location.longitude}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'flutter_app (your_email@example.com)',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'] ?? 'عنوان غير متوفر';
        if (!mounted) return;
        setState(() {
          address = displayName;
          fetchFailed = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          address = 'فشل في جلب العنوان';
          fetchFailed = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        address = 'خطأ في الاتصال أو انتهت المهلة';
        fetchFailed = true;
      });
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      selectedLocation = point;
      address = 'جارٍ تحديد العنوان...';
      fetchFailed = false;
    });
    _getAddressFromLatLng(point);
  }

  void _confirmLocation() async {
    if (selectedLocation != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('تأكيد العنوان'),
          content: Text('هل أنت متأكد من اختيار هذا العنوان؟\n\n$address'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('نعم'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final link =
            'https://www.google.com/maps/search/?api=1&query=${selectedLocation!.latitude},${selectedLocation!.longitude}';
        Navigator.pop(context, {
          'address': address,
          'lat': selectedLocation!.latitude,
          'lng': selectedLocation!.longitude,
          'url': link,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختيار الموقع')),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: selectedLocation ?? LatLng(0.0, 0.0),
                    initialZoom: 16,
                    onTap: (_, point) => _onMapTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: selectedLocation!,
                            child: Icon(Icons.location_pin, size: 40, color: Colors.red),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          address,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        if (fetchFailed)
                          TextButton.icon(
                            onPressed: () => _getAddressFromLatLng(selectedLocation!),
                            icon: Icon(Icons.refresh),
                            label: Text("إعادة جلب العنوان"),
                          ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _confirmLocation,
                          child: Text('تأكيد الموقع'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
