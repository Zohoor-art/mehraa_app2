import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class SignUp2screen extends StatefulWidget {
  final String userId; // استلام معرف المستخدم

  const SignUp2screen({super.key, required this.userId});

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
    _fetchUserData(); // استرجاع بيانات المستخدم
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    if (userDoc.exists) {
      setState(() {
        descriptionController.text = userDoc['description'] ?? ''; // تأكد من إضافة الحقل إذا كان موجودًا
        contactNumberController.text = userDoc['contactNumber'] ?? '';
        locationController.text = userDoc['location'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    contactNumberController.dispose();
    locationController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon, color: MyColor.blueColor),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: MyColor.purpleColor, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyColor.purpleColor, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyColor.purpleColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      // تخزين البيانات في Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'description': descriptionController.text,
        'workType': selectedWorkType,
        'days': selectedDays,
        'hours': selectedHours,
        'contactNumber': contactNumberController.text,
        'location': locationController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ البيانات بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: descriptionController,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'يرجى إدخال وصف العمل';
                                }
                                return null;
                              },
                              decoration: inputDecoration('وصف العمل', Icons.description),
                            ),
                            SizedBox(height: 20.0),
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
                              decoration: inputDecoration('نوع العمل', Icons.business),
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
                              decoration: inputDecoration('الأيام', Icons.calendar_today),
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
                              decoration: inputDecoration('الساعات', Icons.access_time),
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
                              decoration: inputDecoration('رقم تواصل', Icons.phone),
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
                              decoration: inputDecoration('الموقع', Icons.map),
                            ),
                            SizedBox(height: 25),
                            Center(
                              child: GradientButton(
                                onPressed: _saveUserData,
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