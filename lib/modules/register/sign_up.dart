import 'package:flutter/material.dart';
import 'package:mehra_app/modules/signup2/sign_up2.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class SignUpscreen extends StatefulWidget {
  const SignUpscreen({super.key});

  @override
  State<SignUpscreen> createState() => _SignUpscreenState();
}

class _SignUpscreenState extends State<SignUpscreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCountryCode = "+967"; // Default Yemen country code
  final List<String> countryCodes = [
    "+1", // USA
    "+44", // UK
    "+91", // India
    "+967", // Yemen
  ];

  late TextEditingController storeNameController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  bool isPassword = true;

  @override
  void initState() {
    super.initState();
    storeNameController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    storeNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
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
          FocusScope.of(context)
              .unfocus(); // إخفاء لوحة المفاتيح عند النقر خارج الحقل
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
                    height: MediaQuery.of(context).size.height * 0.70,
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
                                top: 70.0, bottom: 40, right: 10, left: 10),
                            child: Column(
                              children: [
                                defultTextFormField(
                                  controller: storeNameController,
                                  type: TextInputType.text,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'يرجى إدخال اسم المتجر';
                                    }
                                    return null;
                                  },
                                  label: 'اسم المتجر',
                                  prefix: Icons.home,
                                ),
                                SizedBox(height: 60.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedCountryCode,
                                        decoration: InputDecoration(
                                          labelText: 'رمز الدولة',
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: MyColor
                                                  .purpleColor, // لون البوردر عند التمكين
                                              width:
                                                  2.0, // سمك البوردر عند التمكين
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: MyColor
                                                  .blueColor, // لون البوردر عند التركيز
                                              width:
                                                  2.3, // سمك البوردر عند التركيز
                                            ),
                                          ),
                                        ),
                                        items: countryCodes.map((String code) {
                                          return DropdownMenuItem<String>(
                                            value: code,
                                            child: Text(code),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedCountryCode = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10.0),
                                    Expanded(
                                      flex: 2,
                                      child: defultTextFormField(
                                        controller: phoneController,
                                        type: TextInputType.phone,
                                        validate: (value) {
                                          if (value!.isEmpty) {
                                            return 'يرجى إدخال رقم الهاتف';
                                          }
                                          if (selectedCountryCode == "+967" &&
                                              value.length != 9) {
                                            return 'يجب أن يحتوي رقم الهاتف على 9 أرقام';
                                          }
                                          return null;
                                        },
                                        label: 'رقم الهاتف',
                                        prefix: Icons.phone,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 60.0),
                                defultTextFormField(
                                  controller: passwordController,
                                  type: TextInputType.visiblePassword,
                                  ispassword: isPassword,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'يرجى إدخال كلمة المرور';
                                    }
                                    if (value.length < 8) {
                                      return 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل';
                                    }
                                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                      return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
                                    }
                                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                                      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
                                    }
                                    return null;
                                  },
                                  label: 'كلمة المرور',
                                  prefix: Icons.lock,
                                  suffix: isPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  suffixPressed: () {
                                    setState(() {
                                      isPassword = !isPassword;
                                    });
                                  },
                                ),
                                SizedBox(height: 50),
                                Center(
                                  child: GradientButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignUp2screen()),
                                      );
                                      if (_formKey.currentState?.validate() ??
                                          false) {
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
