import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class SignUp2screen extends StatefulWidget {
  const SignUp2screen({super.key});

  @override
  State<SignUp2screen> createState() => _SignUpscreenState();
}

class _SignUpscreenState extends State<SignUp2screen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController descriptionController;
  late TextEditingController contactNumberController;
  late TextEditingController locationController;

  String? selectedWorkType;
  String? selectedDays;
  String? selectedHours;

  final List<String> workTypes = [
    'الخياطة',
    'الكيك',
    'الكوافير',
    'أعمال صغيرة أخرى'
  ];

  final List<String> days = [
    'السبت الاحد الاثنين',
    'الاثنين الثلاثاء الاربعاء',
    'الثلاثاء الاربعاء الخميس',
    'السبت الاحد الثلاثاء',
  ];

  final List<String> hours = [
    'من 8 صباحًا إلى 1 ظهرًا',
    'من 1 ظهرًا إلى 8 مساءً',
    'من 8 مساءً إلى منتصف الليل'
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

  void _showContactOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('طريقة توصيل الخدمة')),
          content: Text('اختر طريقة التوصيل:'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // إضافة الكود لتوصيل الخدمة بشكل اختياري
                Navigator.of(context).pop();
              },
              child: Text('توصيل اختياري'),
            ),
            TextButton(
              onPressed: () {
                // إضافة الكود لتوصيل الخدمة بموقع ثابت
                Navigator.of(context).pop();
              },
              child: Text('موقع ثابت'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Container(
              color: MyColor.lightprimaryColor,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/bottom.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  padding: const EdgeInsets.symmetric(vertical: 20.0), // Padding for better spacing
                  child: Card(
                    color: Colors.white,
                    shadowColor: Color(0xFF000000),
                    margin: EdgeInsets.only(bottom: 3.0),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedWorkType,
                              hint: Text('اختر نوع العمل'),
                              items: workTypes.map((String workType) {
                                return DropdownMenuItem<String>(
                                  value: workType,
                                  child: Text(workType),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedWorkType = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار نوع العمل';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'نوع العمل',
                                prefixIcon: Icon(
                                  Icons.business,
                                  color: MyColor.blueColor,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MyColor.blueColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: descriptionController,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال وصف العمل';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'وصف العمل',
                                prefixIcon: Icon(
                                  Icons.description,
                                  color: MyColor.blueColor,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MyColor.blueColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            DropdownButtonFormField<String>(
                              value: selectedDays,
                              hint: Text('اختر الأيام'),
                              items: days.map((String day) {
                                return DropdownMenuItem<String>(
                                  value: day,
                                  child: Text(day),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDays = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار الأيام';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'الأيام',
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  color: MyColor.blueColor,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MyColor.blueColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            DropdownButtonFormField<String>(
                              value: selectedHours,
                              hint: Text('اختر الساعات'),
                              items: hours.map((String hour) {
                                return DropdownMenuItem<String>(
                                  value: hour,
                                  child: Text(hour),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedHours = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار الساعات';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'الساعات',
                                prefixIcon: Icon(
                                  Icons.access_time,
                                  color: MyColor.blueColor,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MyColor.blueColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: contactNumberController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال رقم تواصل';
                                }
                                return null;
                              },
                              onTap: _showContactOptions,
                              decoration: InputDecoration(
                                labelText: 'رقم تواصل',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: MyColor.blueColor,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MyColor.blueColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: locationController,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال الموقع';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'الموقع',
                                prefixIcon: Icon(
                                  Icons.map,
                                  color: MyColor.blueColor,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MyColor.blueColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 25),
                            Center(
                              child: GradientButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    // Proceed with the sign-up process
                                  }
                                },
                                text: 'التحقق',
                                width: 319,
                                height: 67,
                              ),
                            ),
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