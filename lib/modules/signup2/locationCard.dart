// import 'package:flutter/material.dart';
// import 'package:mehra_app/modules/signup2/locationMap.dart';

// class LocationSelectionCard extends StatefulWidget {
//   final TextEditingController locationController;

//   LocationSelectionCard(this.locationController);

//   @override
//   _LocationSelectionCardState createState() => _LocationSelectionCardState();
// }

// class _LocationSelectionCardState extends State<LocationSelectionCard> {
//   final manualController = TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   String? selectedArea;
//   String? manualAddress;
//   String? mapAddressUrl;
//   String? selectedMapAddress;
//   double? selectedLat;
//   double? selectedLng;
//   bool isManualSelected = false;
//   bool isMapSelected = false;

//   final List<String> areas = ['شملان', 'مذبح', 'الستين', 'ضلاع'];

//   @override
//   void dispose() {
//     manualController.dispose();
//     super.dispose();
//   }

//   void _selectMapAddress() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => MapSelectionScreen()),
//     );

//     if (result != null && result is Map) {
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text("تأكيد الموقع"),
//           content: Text("هل ترغب في استخدام هذا العنوان؟\n\n${result['address']}"),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context, false), child: Text("إلغاء")),
//             TextButton(onPressed: () => Navigator.pop(context, true), child: Text("تأكيد")),
//           ],
//         ),
//       );

//       if (confirm == true) {
//         setState(() {
//           mapAddressUrl = result['url'];
//           selectedMapAddress = result['address'];
//           selectedLat = result['lat'] as double;
//           selectedLng = result['lng'] as double;
//           isMapSelected = true;
//           isManualSelected = false;
//           manualAddress = null;
//         });
//       }
//     }
//   }

//   void _saveLocation() async {
//     final isValid = formKey.currentState!.validate();
//     if (!isValid) return;

//     // تحقق من تحديد إما الخريطة أو العنوان اليدوي
//     if (!isMapSelected) {
//       if (manualController.text.trim().isNotEmpty) {
//         manualAddress = manualController.text.trim();
//         isManualSelected = true;
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("يرجى اختيار طريقة لإدخال العنوان")),
//         );
//         return;
//       }
//     }

//     // إعداد النص النهائي
//     String finalText = selectedArea!;
//     if (isManualSelected) {
//       finalText += ' - $manualAddress';
//     } else if (isMapSelected && selectedMapAddress != null) {
//       finalText += ' - $selectedMapAddress';
//     }

//     // تأكيد نهائي قبل الحفظ
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("تأكيد الحفظ"),
//         content: Text("هل ترغب في حفظ هذا الموقع؟\n\n$finalText"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: Text("إلغاء")),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: Text("تأكيد")),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       Navigator.pop(context, {
//         'fullText': finalText,
//         'area': selectedArea,
//         'manual': isManualSelected ? manualAddress : null,
//         'mapUrl': mapAddressUrl,
//         'lat': selectedLat,
//         'lng': selectedLng,
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
//       child: SingleChildScrollView(
//         child: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButtonFormField<String>(
//                 value: selectedArea,
//                 hint: Text("اختيار منطقة السكن"),
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'المنطقة',
//                 ),
//                 items: areas
//                     .map((area) => DropdownMenuItem(value: area, child: Text(area)))
//                     .toList(),
//                 onChanged: (value) => setState(() => selectedArea = value),
//                 validator: (value) => value == null ? "يرجى اختيار المنطقة" : null,
//               ),
//               SizedBox(height: 16),

//               TextFormField(
//                 controller: manualController,
//                 decoration: InputDecoration(
//                   hintText: 'مثال: شملان شارع الثلاثين حي البر',
//                   labelText: 'إدخال العنوان يدويًا',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 2,
//               ),

//               Divider(),

//               ElevatedButton.icon(
//                 onPressed: _selectMapAddress,
//                 icon: Icon(Icons.map),
//                 label: Text("اختيار من الخريطة"),
//               ),
//               if (isMapSelected && selectedMapAddress != null) ...[
//                 SizedBox(height: 10),
//                 Text(
//                   "العنوان المختار من الخريطة:\n$selectedMapAddress",
//                   textAlign: TextAlign.center,
//                 ),
//               ],

//               SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _saveLocation,
//                 child: Text("حفظ"),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 48),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:mehra_app/modules/signup2/locationMap.dart';
import 'package:mehra_app/shared/components/constants.dart';

class LocationSelectionCard extends StatefulWidget {
  final TextEditingController locationController;

  LocationSelectionCard(this.locationController);

  @override
  _LocationSelectionCardState createState() => _LocationSelectionCardState();
}

class _LocationSelectionCardState extends State<LocationSelectionCard> {
  final manualController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? selectedArea;
  String? manualAddress;
  String? mapAddressUrl;
  String? selectedMapAddress;
  double? selectedLat;
  double? selectedLng;
  bool isManualSelected = false;
  bool isMapSelected = false;

  final List<String> areas = ['شملان', 'مذبح', 'الستين', 'ضلاع'];

  @override
  void dispose() {
    manualController.dispose();
    super.dispose();
  }

  void _selectMapAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapSelectionScreen()),
    );

    if (result != null && result is Map) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 48, color: MyColor.blueColor),
                SizedBox(height: 16),
                Text(
                  "تأكيد الموقع",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  result['address'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("إلغاء"),
                    )),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: MyColor.blueColor,
                        ),
                        child: Text("تأكيد"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (confirm == true) {
        setState(() {
          mapAddressUrl = result['url'];
          selectedMapAddress = result['address'];
          selectedLat = result['lat'] as double;
          selectedLng = result['lng'] as double;
          isMapSelected = true;
          isManualSelected = false;
          manualAddress = null;
        });
      }
    }
  }

  void _saveLocation() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (!isMapSelected) {
      if (manualController.text.trim().isNotEmpty) {
        manualAddress = manualController.text.trim();
        isManualSelected = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("يرجى اختيار طريقة لإدخال العنوان"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
        return;
      }
    }

    String finalText = selectedArea!;
    if (isManualSelected) {
      finalText += ' - $manualAddress';
    } else if (isMapSelected && selectedMapAddress != null) {
      finalText += ' - $selectedMapAddress';
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 48, color: MyColor.blueColor),
              SizedBox(height: 16),
              Text(
                "تأكيد الحفظ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                finalText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("إلغاء"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: MyColor.blueColor,
                      ),
                      child: Text(
                        "حفظ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      Navigator.pop(context, {
        'fullText': finalText,
        'area': selectedArea,
        'manual': isManualSelected ? manualAddress : null,
        'mapUrl': mapAddressUrl,
        'lat': selectedLat,
        'lng': selectedLng,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: [
                  Icon(Icons.location_pin, size: 40, color: MyColor.blueColor),
                  SizedBox(height: 8),
                  Text(
                    'تحديد موقع السكن',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: MyColor.blueColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اختر موقع سكنك من أحد الخيارات التالية',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Area Selection
              Text(
                'المنطقة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: selectedArea,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "اختر منطقتك",
                    ),
                    items: areas
                        .map((area) => DropdownMenuItem(
                              value: area,
                              child: Text(area),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedArea = value),
                    validator: (value) =>
                        value == null ? "يرجى اختيار المنطقة" : null,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Manual Address
              Text(
                'أو أدخل العنوان يدوياً',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: manualController,
                decoration: InputDecoration(
                  hintText: 'مثال: شملان شارع الثلاثين حي البر',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 24),

              // Divider with text
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("أو"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 24),

              // Map Selection
              OutlinedButton.icon(
                onPressed: _selectMapAddress,
                icon: Icon(Icons.map_outlined, color: MyColor.blueColor),
                label: Text(
                  "تحديد على الخريطة",
                  style: TextStyle(color: MyColor.blueColor),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: MyColor.blueColor),
                ),
              ),
              if (isMapSelected && selectedMapAddress != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MyColor.blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: MyColor.blueColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: MyColor.blueColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "تم اختيار الموقع:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              selectedMapAddress!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: MyColor.blueColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveLocation,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: MyColor.blueColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                child: Text(
                  "حفظ الموقع",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
