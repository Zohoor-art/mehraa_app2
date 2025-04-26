import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isPassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final local = AppLocalizations.of(context)!;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String message = local.errorOccurred;

        if (e.code == 'user-not-found') {
          message = local.userNotFound;
        } else if (e.code == 'wrong-password') {
          message = local.wrongPassword;
        }

        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: local.error,
          desc: message,
          btnOkOnPress: () {},
          btnOkColor: Colors.red,
        ).show();
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

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
            Container(color: MyColor.lightprimaryColor),
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
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Card(
                    color: Colors.white,
                    shadowColor: Colors.black,
                    margin: EdgeInsets.only(bottom: 3.0),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0, bottom: 40, right: 10, left: 10),
                          child: Column(
                            children: [
                              SizedBox(height: 20.0),
                              defultTextFormField(
                                controller: emailController,
                                label: local.email,
                                prefix: Icons.email,
                                type: TextInputType.emailAddress,
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return local.enterEmail;
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 30.0),
                              defultTextFormField(
                                controller: passwordController,
                                type: TextInputType.visiblePassword,
                                ispassword: isPassword,
                                label: local.password,
                                prefix: Icons.lock,
                                suffix: isPassword ? Icons.visibility_off : Icons.visibility,
                                suffixPressed: () {
                                  setState(() {
                                    isPassword = !isPassword;
                                  });
                                },
                                validate: (value) {
                                  if (value!.isEmpty) return local.enterPassword;
                                  if (value.length < 8) return local.passwordTooShort;
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) return local.passwordUppercase;
                                  if (!RegExp(r'[0-9]').hasMatch(value)) return local.passwordNumber;
                                  return null;
                                },
                              ),
                              SizedBox(height: 30),
                              Center(
                                child: GradientButton(
                                  onPressed: _login,
                                  text: local.login,
                                  width: 319,
                                  height: 67,
                                ),
                              ),
                              SizedBox(height: 30),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                                    );
                                  },
                                  child: Text(
                                    local.noAccount,
                                    style: TextStyle(fontSize: 18, color: Colors.black),
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
          ],
        ),
      ),
    );
  }
}
