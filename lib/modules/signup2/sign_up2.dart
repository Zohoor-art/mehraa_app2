import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:day_picker/day_picker.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/firebase/auth_methods.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  String? selectedDays;
  String? selectedHours;
  bool isLoading = false;

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

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: MyColor.blueColor),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: MyColor.purpleColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyColor.purpleColor),
      ),
    );
  }

  Future<void> _completeRegistration() async {
    if (_formKey.currentState!.validate() &&
        selectedWorkType != null &&
        selectedDays != null &&
        selectedHours != null) {
      setState(() => isLoading = true);

      final authMethods = AuthMethods();
      final result = await authMethods.completeSignUpProcess(
        userId: widget.userId,
        contactNumber: contactNumberController.text.trim(),
        days: selectedDays!,
        description: descriptionController.text.trim(),
        email: widget.email,
        hours: selectedHours!,
        location: locationController.text.trim(),
        profileImage: widget.profileImage,
        storeName: widget.storeName,
        workType: selectedWorkType!,
      );

      setState(() => isLoading = false);

      if (result == "success") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'خطأ',
          desc: result,
          btnOkOnPress: () {},
        ).show();
      }
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'تحذير',
        desc: 'الرجاء ملء جميع الحقول المطلوبة',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    final List<DayInWeek> days = [
      DayInWeek("السبت", dayKey: "saturday"),
      DayInWeek("الأحد", dayKey: "sunday"),
      DayInWeek("الاثنين", dayKey: "monday"),
      DayInWeek("الثلاثاء", dayKey: "tuesday"),
      DayInWeek("الأربعاء", dayKey: "wednesday"),
      DayInWeek("الخميس", dayKey: "thursday"),
      DayInWeek("الجمعة", dayKey: "friday", isSelected: true),
    ];

    final List<String> workTypes = [
      'الخياطة',
      'الكيك',
      'الكوافير',
      'أعمال صغيرة أخرى'
    ];

    final List<String> hours = [
      'من 8 صباحًا إلى 1 ظهرًا',
      'من 1 ظهرًا إلى 8 مساءً',
      'من 8 مساءً إلى منتصف الليل'
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
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
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
              ),
              child: Center(
                child: Container(
                  width: isSmallScreen ? screenWidth * 0.95 : screenWidth * 0.9,
                  constraints: BoxConstraints(
                    minHeight: screenHeight * 0.7,
                    maxHeight: screenHeight * 0.9,
                  ),
                  margin: EdgeInsets.only(bottom: 20),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'إكمال بيانات المتجر',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MyColor.blueColor,
                              ),
                            ),
                            SizedBox(height: 20),
                            defultTextFormField(
                              controller: descriptionController,
                              type: TextInputType.text,
                              label: "الوصف",
                              prefix: Icons.description,
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال وصف العمل';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            DropdownButtonFormField<String>(
                              value: selectedWorkType,
                              hint: Text('اختر نوع العمل'),
                              items: workTypes
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedWorkType = value),
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار نوع العمل';
                                }
                                return null;
                              },
                              decoration:
                                  inputDecoration('نوع العمل', Icons.business),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            SelectWeekDays(
                              days: days,
                              border: false,
                              boxDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [MyColor.blueColor, MyColor.purpleColor],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              onSelect: (values) {
                                setState(() {
                                  selectedDays = values.join(", ");
                                });
                              },
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            DropdownButtonFormField<String>(
                              value: selectedHours,
                              hint: Text('اختر الساعات'),
                              items: hours
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedHours = value),
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار الساعات';
                                }
                                return null;
                              },
                              decoration:
                                  inputDecoration('الساعات', Icons.access_time),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            defultTextFormField(
                              controller: contactNumberController,
                              type: TextInputType.phone,
                              label: 'رقم التواصل',
                              prefix: Icons.phone,
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال رقم تواصل';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            defultTextFormField(
                              controller: locationController,
                              type: TextInputType.text,
                              label: 'الموقع',
                              prefix: Icons.map,
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال الموقع';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            GradientButton(
                              onPressed: _completeRegistration,
                              text: isLoading
                                  ? 'جارٍ التسجيل...'
                                  : 'إكمال التسجيل',
                              width: isSmallScreen ? screenWidth * 0.8 : 319,
                              height: isSmallScreen ? 50 : 67,
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
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
