import 'package:flutter/material.dart';
import 'package:mehra_app/models/model.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

var boardController = PageController();

TextStyle headlingtext() => TextStyle(
    color: Color(0xff514D4D),
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    fontFamily: 'Tajawal');

Widget gradientColor() => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4423B1),
            Color(0xFF6B2298),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
Widget buildOnboardingItem(BoardingModel model) => Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Image(
              image: AssetImage(model.image),
              width: 250,
              height: 250,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            model.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              model.body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontFamily: 'Tajawal'),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );

Widget bottomImage() => Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image(
          image: AssetImage('assets/bottom.png'),
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 135,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(35),
            ),
            alignment: Alignment.center,
          ),
        ),
      ],
    );

Widget GradientButton(
    {required VoidCallback onPressed,
    required text,
    double? width,
    double? height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF4423B1),
          Color(0xFFA02D87),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2), // ظل خفيف
          spreadRadius: 1,
          blurRadius: 7,
          offset: Offset(0, 3), // موضع الظل
        ),
      ],
    ),
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        textAlign: TextAlign.center,
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 22, fontFamily: 'Tajawal'),
      ),
    ),
  );
}

Widget buildGoogleButton(
    {required String text, required VoidCallback onPressed}) {
  return Container(
    width: 346,
    height: 75,
    decoration: BoxDecoration(
      color: Colors.white, // خلفية بيضاء
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2), // ظل خفيف
          spreadRadius: 1,
          blurRadius: 7,
          offset: Offset(0, 3), // موضع الظل
        ),
      ],
    ),
    child: TextButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Image.asset(
              'assets/images/google.png', // مسار الأيقونة
              width: 42, // عرض الأيقونة
              height: 42, // ارتفاع الأيقونة
            ),
            SizedBox(width: 15),

            // المسافة بين الأيقونة والنص
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 23,
                fontWeight: FontWeight.w500, // جعل النص عريض
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget smooth_page_indicator() => Center(
      child: SmoothPageIndicator(
        controller: boardController,
        effect: const ExpandingDotsEffect(
          dotColor: Color(0xFFC4BCBC),
          activeDotColor: Color(0xFF4423B1),
          dotHeight: 10,
          dotWidth: 10,
          expansionFactor: 2,
          paintStyle: PaintingStyle.fill,
          spacing: 5.0,
        ),
        count: boarding.length,
      ),
    );

class SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget trailing;
  final CrossAxisAlignment alignment;

  SettingTile(
      {required this.title,
      required this.icon,
      required this.trailing,
      required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(16.0),
        height: 70,
        decoration: BoxDecoration(
          color: MyColor.backcardsetting,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 7.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF5E4B8A)), // لون الأيقونة
                SizedBox(width: 16.0),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Color(0xFF333333)),
                ),
              ],
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

Widget defultTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  void Function(String)? onSubmit,
  void Function(String)? onChanged,
  required String? Function(String?) validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  bool ispassword = false,
  void Function()? suffixPressed,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      onFieldSubmitted: onSubmit,
      onChanged: onChanged,
      style: TextStyle(fontSize: 18),
      validator: validate,
      obscureText: ispassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 18), 
        prefixIcon: Icon(prefix, color: MyColor.purpleColor), // لون الأيقونة بنفسجي
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed,
                icon: Icon(suffix, color: MyColor.purpleColor), // لون الأيقونة بنفسجي
              )
            : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: MyColor.purpleColor, // لون البوردر بنفسجي
            width: 2.0, // سمك البوردر
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: MyColor.purpleColor, // لون البوردر عند التمكين
            width: 2.0, // سمك البوردر عند التمكين
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: MyColor.blueColor, // لون البوردر عند التركيز
            width: 2.5, // سمك البوردر عند التركيز
          ),
        ),
      ),
    );
