import 'package:flutter/material.dart';
import 'package:mehra_app/models/firebase/auth_methods.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/signup2/locationCard.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class SignUp2screen extends StatefulWidget {
  final String userId;
  final String email;
  final String storeName;
  final String profileImage;

  const SignUp2screen({
    super.key,
    required this.userId,
    required this.email,
    required this.storeName,
    required this.profileImage,
  });

  @override
  State<SignUp2screen> createState() => _SignUp2screenState();
}

class _SignUp2screenState extends State<SignUp2screen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController descriptionController;
  late TextEditingController contactNumberController;
  late TextEditingController locationController;

  String? selectedWorkType;
  List<String> selectedDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isLoading = false;
  String? locationUrl;
  double? latitude;
  double? longitude;
  String? selectedArea;

  final List<Map<String, dynamic>> days = [
    {'name': 'السبت', 'value': 'السبت'},
    {'name': 'الأحد', 'value': 'الأحد'},
    {'name': 'الاثنين', 'value': 'الاثنين'},
    {'name': 'الثلاثاء', 'value': 'الثلاثاء'},
    {'name': 'الأربعاء', 'value': 'الأربعاء'},
    {'name': 'الخميس', 'value': 'الخميس'},
    {'name': 'الجمعة', 'value': 'الجمعة'},
  ];

  final List<String> workTypes = [
    'الخياطة',
    'الكيك',
    'الكوافير',
    'أعمال صغيرة أخرى'
  ];

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
    contactNumberController = TextEditingController();
    locationController = TextEditingController();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    contactNumberController.dispose();
    locationController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.black.withOpacity(0.6),
      ),
      prefixIcon: Icon(icon, color: MyColor.purpleColor),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: MyColor.purpleColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyColor.purpleColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyColor.purpleColor, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _completeRegistration() async {
    if (_formKey.currentState!.validate() &&
        selectedWorkType != null &&
        selectedDays.isNotEmpty &&
        startTime != null &&
        endTime != null &&
        selectedArea != null) {
      setState(() => isLoading = true);

      final hours = '${_formatTime(startTime!)} - ${_formatTime(endTime!)}';

      final authMethods = AuthMethods();
      final result = await authMethods.completeSignUpProcess(
        userId: widget.userId,
        contactNumber: contactNumberController.text.trim(),
        days: selectedDays.join(", "), // سيتم حفظ الأسماء العربية مباشرة
        description: descriptionController.text.trim(),
        email: widget.email,
        hours: hours,
        location: selectedArea!,
        locationUrl: locationUrl!,
        latitude: latitude,
        longitude: longitude,
        profileImage: widget.profileImage,
        storeName: widget.storeName,
        workType: selectedWorkType!,
      );

      setState(() => isLoading = false);

      if (result == 'success') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("يرجى تعبئة جميع الحقول المطلوبة")));
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime
        ? startTime ?? TimeOfDay(hour: 8, minute: 0)
        : endTime ?? TimeOfDay(hour: 17, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MyColor.blueColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  void _toggleDaySelection(String dayValue) {
    setState(() {
      if (selectedDays.contains(dayValue)) {
        selectedDays.remove(dayValue);
      } else {
        selectedDays.add(dayValue);
      }
    });
  }

  Future<void> _showDaysSelectionDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(top: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('اختر أيام العمل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.6),
                      )),
                  SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final isSelected = selectedDays.contains(day['value']);
                        return CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                _toggleDaySelection(day['value']);
                              });
                            },
                            title: Text(day['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected
                                      ? MyColor.blueColor
                                      : Colors.black,
                                )),
                            secondary: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? MyColor.purpleColor
                                  : Colors.grey,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            activeColor: MyColor.purpleColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ));
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('تم',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: MyColor.purpleColor, width: 2),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              time != null ? _formatTime(time) : label,
              style: TextStyle(
                fontSize: 14,
                color: time != null ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysButton() {
    return Expanded(
      flex: 3,
      child: InkWell(
        onTap: () => _showDaysSelectionDialog(context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: MyColor.purpleColor, width: 2),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  selectedDays.isEmpty
                      ? 'أيام العمل'
                      : '${selectedDays.length} يوم',
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDays.isNotEmpty
                        ? Colors.black
                        : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.calendar_today, color: MyColor.purpleColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.blueColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(color: MyColor.lightprimaryColor),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/bottom.png',
                fit: BoxFit.cover,
                width: screenWidth,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: screenHeight * 0.1,
                ),
                child: Container(
                  width: isSmallScreen ? screenWidth * 0.95 : screenWidth * 0.9,
                  margin: EdgeInsets.only(bottom: screenHeight * 0.12),
                  child: Card(
                    color: Colors.white,
                    shadowColor: const Color(0xFF000000),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.store,
                                    size: 40,
                                    color: MyColor.blueColor,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'إكمال بيانات المتجر',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: MyColor.blueColor,
                                    ),
                                  ),
                                  Text(
                                    'الخطوة الأخيرة لبدء استخدام التطبيق',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // وصف المتجر
                            TextFormField(
                              controller: descriptionController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 2,
                              decoration: _buildInputDecoration(
                                  "وصف المتجر", Icons.note),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال وصف المتجر';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // نوع العمل
                            DropdownButtonFormField<String>(
                              value: selectedWorkType,
                              hint: Text('اختر نوع العمل',
                                  style: TextStyle(color: Colors.grey[600])),
                              items: workTypes
                                  .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e,
                                          style:
                                              TextStyle(color: Colors.black))))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedWorkType = value),
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار نوع العمل';
                                }
                                return null;
                              },
                              decoration: _buildInputDecoration(
                                  'نوع العمل', Icons.shopping_cart),
                              dropdownColor: Colors.white,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: MyColor.blueColor),
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // صف الأيام والساعات
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أيام وساعات العمل',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    // زر أيام العمل
                                    _buildDaysButton(),
                                    SizedBox(width: 8),

                                    // ساعات العمل
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          _buildTimeField('من', startTime,
                                              () => _selectTime(context, true)),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Text('',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: MyColor.blueColor)),
                                          ),
                                          _buildTimeField(
                                              'الى',
                                              endTime,
                                              () =>
                                                  _selectTime(context, false)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // رقم التواصل
                            TextFormField(
                              controller: contactNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration(
                                  'رقم التواصل', Icons.phone),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال رقم التواصل';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // الموقع
                            TextFormField(
                              controller: locationController,
                              keyboardType: TextInputType.text,
                              decoration: _buildInputDecoration(
                                  'الموقع', Icons.location_on),
                              readOnly: true,
                              onTap: () async {
                                final result = await showModalBottomSheet<
                                    Map<String, dynamic>>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      LocationSelectionCard(locationController),
                                );

                                if (result != null) {
                                  locationController.text = result['fullText'];
                                  selectedArea = result['area'];
                                  locationUrl =
                                      result['mapUrl'] ?? result['manual'];
                                  latitude = result['lat'];
                                  longitude = result['lng'];
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال الموقع';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // زر الإرسال
                            GradientButton(
                              onPressed: _completeRegistration,
                              text:
                                  isLoading ? 'جارٍ الحفظ...' : 'اكمال التسجيل',
                              width: isSmallScreen ? screenWidth * 0.8 : 319,
                              height: isSmallScreen ? 50 : 67,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
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
}
