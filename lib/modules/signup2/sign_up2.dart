import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:day_picker/day_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
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

  final List<String> hours = [
    'من 8 صباحًا إلى 1 ظهرًا',
    'من 1 ظهرًا إلى 8 مساءً',
    'من 8 مساءً إلى منتصف الليل'
  ];

  final List<DayInWeek> days = [
    DayInWeek("السبت", dayKey: "monday"),
    DayInWeek("الأحد", dayKey: "sunday"),
    DayInWeek("الاثنين", dayKey: "tuesday"),
    DayInWeek("الثلاثاء", dayKey: "wednesday"),
    DayInWeek("الأربعاء", dayKey: "thursday"),
    DayInWeek("الخميس", dayKey: "friday"),
    DayInWeek("الجمعة", dayKey: "saturday", isSelected: true),
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
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      setState(() {
        descriptionController.text = userDoc['description'] ?? '';
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

  Future<void> _saveUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // تخزين البيانات في Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'description': descriptionController.text,
          'workType': selectedWorkType,
          'days': selectedDays,
          'hours': selectedHours,
          'contactNumber': contactNumberController.text,
          'location': locationController.text,
        });

        // إرسال كود التحقق إلى البريد الإلكتروني
        await _sendVerificationEmail();

        // عرض رسالة النجاح باستخدام AwesomeDialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'نجاح',
          desc:
              'تم حفظ البيانات بنجاح وتم إرسال كود التحقق إلى بريدك الإلكتروني.',
          btnOkOnPress: () {
            // يمكن الانتقال إلى الصفحة الرئيسية هنا إذا أردت
          },
          btnOkColor: MyColor.purpleColor,
        ).show();
      } catch (e) {
        print("Error: $e");
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'حدث خطأ',
          desc: e.toString(),
          btnOkOnPress: () {},
          btnOkColor: Colors.red,
        ).show();
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.scale,
        title: 'تم إرسال كود التحقق',
        desc: 'يرجى التحقق من بريدك الإلكتروني.',
        btnOkOnPress: () async {
          // الانتظار حتى يتحقق المستخدم من بريده الإلكتروني
          await _checkEmailVerification();
        },
      ).show();
    } catch (e) {
      print("Error sending verification email: $e");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'حدث خطأ',
        desc: e.toString(),
        btnOkOnPress: () {},
        btnOkColor: Colors.red,
      ).show();
    }
  }

  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    // الانتظار حتى يتم التحقق من البريد الإلكتروني
    while (user != null && !user.emailVerified) {
      await Future.delayed(Duration(seconds: 3)); // الانتظار لمدة 3 ثواني
      await user.reload(); // إعادة تحميل معلومات المستخدم
      user = FirebaseAuth.instance.currentUser; // تحديث المتغير
    }

    // الانتقال إلى الصفحة الرئيسية بعد التحقق من البريد الإلكتروني
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => HomeScreen(),
    ));
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
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Card(
                        color: Colors.white,
                        shadowColor: Color(0xFF000000),
                        margin: EdgeInsets.only(bottom: 3.0),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, bottom: 10, right: 10, left: 10),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: defultTextFormField(
                                      controller: descriptionController,
                                      type: TextInputType.text,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'يرجى إدخال وصف العمل';
                                        }
                                        return null;
                                      },
                                      label: 'وصف العمل',
                                      prefix: Icons.description,
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
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
                                      decoration: inputDecoration('نوع العمل',
                                          Icons.business), // إضافة الديكور هنا
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SelectWeekDays(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        days: days,
                                        border: false,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.4,
                                        boxDecoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              MyColor.blueColor,
                                              MyColor.purpleColor
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        onSelect: (values) {
                                          print(values);
                                          setState(() {
                                            selectedDays = values.join(", ");
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
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
                                      decoration: inputDecoration(
                                          'الساعات',
                                          Icons
                                              .access_time), // إضافة الديكور هنا
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Expanded(
                                    child: defultTextFormField(
                                      controller: contactNumberController,
                                      label: 'رقم التواصل',
                                      prefix: Icons.phone,
                                      type: TextInputType.phone,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'يرجى إدخال رقم تواصل';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Expanded(
                                    child: defultTextFormField(
                                      controller: locationController,
                                      label: 'الموقع',
                                      prefix: Icons.map,
                                      type: TextInputType.text,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'يرجى إدخال الموقع';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Expanded(
                                    child: Center(
                                      child: GradientButton(
                                        onPressed:
                                            _saveUserData, // استدعاء الدالة هنا
                                        text: 'التحقق',
                                        width: 319,
                                        height: 67,
                                      ),
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
                ),
              )
            ],
          ),
        ));
  }
}