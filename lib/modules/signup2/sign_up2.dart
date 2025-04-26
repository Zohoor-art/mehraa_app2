import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:day_picker/day_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUp2screen extends StatefulWidget {
  final String userId;

  const SignUp2screen({super.key, required this.userId});

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

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
    contactNumberController = TextEditingController();
    locationController = TextEditingController();
    _fetchUserData();
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
    final local = AppLocalizations.of(context)!;

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

        await _sendVerificationEmail();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: local.verify,
          desc: local.ok,
          btnOkOnPress: () {},
          btnOkColor: MyColor.purpleColor,
        ).show();
      } catch (e) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: local.error,
          desc: e.toString(),
          btnOkOnPress: () {},
          btnOkColor: Colors.red,
        ).show();
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    final local = AppLocalizations.of(context)!;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.scale,
        title: local.verify,
        desc: local.ok,
        btnOkOnPress: () async {
          await _checkEmailVerification();
        },
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: local.error,
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
      await Future.delayed(Duration(seconds: 3));
      await user.reload();
      user = FirebaseAuth.instance.currentUser;
    }


// الانتقال إلى الصفحة الرئيسية بعد التحقق من البريد الإلكتروني
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => HomeScreen(),
    ));

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

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    final List<DayInWeek> days = [
      DayInWeek(local.sat, dayKey: "saturday"),
      DayInWeek(local.sun, dayKey: "sunday"),
      DayInWeek(local.mon, dayKey: "monday"),
      DayInWeek(local.tue, dayKey: "tuesday"),
      DayInWeek(local.wed, dayKey: "wednesday"),
      DayInWeek(local.thu, dayKey: "thursday"),
      DayInWeek(local.fri, dayKey: "friday", isSelected: true),
    ];

    final List<String> workTypes = [
      local.tailoring,
      local.cake,
      local.hairdresser,
      local.otherSmallBusiness,
    ];

    final List<String> hours = [
      local.hoursMorning,
      local.hoursAfternoon,
      local.hoursEvening,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(color: MyColor.lightprimaryColor),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset('assets/bottom.png', fit: BoxFit.cover),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  padding: EdgeInsets.all(10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        defultTextFormField(
                          controller: descriptionController,
                          type: TextInputType.text,
                          label: local.description,
                          prefix: Icons.description,
                          validate: (value) =>
                              value!.isEmpty ? local.enterDescription : null,
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedWorkType,
                          hint: Text(local.selectWorkType),
                          items: workTypes
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedWorkType = value),
                          validator: (value) =>
                              value == null ? local.mustSelectWorkType : null,
                          decoration:
                              inputDecoration(local.workType, Icons.business),
                        ),
                        SizedBox(height: 10),
                        SelectWeekDays(
                          days: days,
                          border: false,
                          boxDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                MyColor.blueColor,
                                MyColor.purpleColor
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onSelect: (values) {
                            setState(() {
                              selectedDays = values.join(", ");
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedHours,
                          hint: Text(local.selectHours),
                          items: hours
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedHours = value),
                          validator: (value) =>
                              value == null ? local.mustSelectHours : null,
                          decoration:
                              inputDecoration(local.hours, Icons.access_time),
                        ),
                        SizedBox(height: 10),
                        defultTextFormField(
                          controller: contactNumberController,
                          type: TextInputType.phone,
                          label: local.contactNumber,
                          prefix: Icons.phone,
                          validate: (value) =>
                              value!.isEmpty ? local.enterContactNumber : null,
                        ),
                        SizedBox(height: 10),
                        defultTextFormField(
                          controller: locationController,
                          type: TextInputType.text,
                          label: local.location,
                          prefix: Icons.map,
                          validate: (value) =>
                              value!.isEmpty ? local.enterLocation : null,
                        ),
                        SizedBox(height: 20),
                        GradientButton(
                          onPressed: _saveUserData,
                          text: local.verify,
                          width: 319,
                          height: 67,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
