import 'package:flutter/material.dart';
import 'package:mehra_app/modules/signup2/locationMap.dart';

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
        builder: (_) => AlertDialog(
          title: Text("تأكيد الموقع"),
          content: Text("هل ترغب في استخدام هذا العنوان؟\n\n${result['address']}"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text("إلغاء")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text("تأكيد")),
          ],
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

    // تحقق من تحديد إما الخريطة أو العنوان اليدوي
    if (!isMapSelected) {
      if (manualController.text.trim().isNotEmpty) {
        manualAddress = manualController.text.trim();
        isManualSelected = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("يرجى اختيار طريقة لإدخال العنوان")),
        );
        return;
      }
    }

    // إعداد النص النهائي
    String finalText = selectedArea!;
    if (isManualSelected) {
      finalText += ' - $manualAddress';
    } else if (isMapSelected && selectedMapAddress != null) {
      finalText += ' - $selectedMapAddress';
    }

    // تأكيد نهائي قبل الحفظ
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تأكيد الحفظ"),
        content: Text("هل ترغب في حفظ هذا الموقع؟\n\n$finalText"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("تأكيد")),
        ],
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
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedArea,
                hint: Text("اختيار منطقة السكن"),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'المنطقة',
                ),
                items: areas
                    .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                    .toList(),
                onChanged: (value) => setState(() => selectedArea = value),
                validator: (value) => value == null ? "يرجى اختيار المنطقة" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: manualController,
                decoration: InputDecoration(
                  hintText: 'مثال: شملان شارع الثلاثين حي البر',
                  labelText: 'إدخال العنوان يدويًا',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              Divider(),

              ElevatedButton.icon(
                onPressed: _selectMapAddress,
                icon: Icon(Icons.map),
                label: Text("اختيار من الخريطة"),
              ),
              if (isMapSelected && selectedMapAddress != null) ...[
                SizedBox(height: 10),
                Text(
                  "العنوان المختار من الخريطة:\n$selectedMapAddress",
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveLocation,
                child: Text("حفظ"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
