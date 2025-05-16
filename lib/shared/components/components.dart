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
          fit: BoxFit.fill,
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

Widget GradientButton({
  required VoidCallback onPressed,
  required String text,
  double? fontSize , // قيمة افتراضية لحجم الخط
  double? width,
  double? height,
}) {
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
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 7,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize, // استخدام قيمة fontSize الممررة
          fontFamily: 'Tajawal',
        ),
      ),
    ),
  );
}
Widget buildGoogleButton(
    {required String text,  
    double? fontSize , // قيمة افتراضية لحجم الخط
 required VoidCallback onPressed}) {
  return Expanded(
    child: Container(
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
          padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 10),
          child: Row(
            children: [
              Image.asset(
                'assets/images/google.png', // مسار الأيقونة
                width: 42, // عرض الأيقونة
                height: 42, // ارتفاع الأيقونة
              ),
              SizedBox(width: 10),
    
              // المسافة بين الأيقونة والنص
              Text(
                text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500, // جعل النص عريض
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}



class SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget trailing;
  final CrossAxisAlignment alignment;
  final VoidCallback? onTap; // أضفنا هذا السطر

  SettingTile({
    required this.title,
    required this.icon,
    required this.trailing,
    required this.alignment,
    this.onTap, // وأضفنا هذا
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: onTap, // هذه اللي تفعل الضغط
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
                  Icon(icon, color: Color(0xFF5E4B8A)),
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
   bool readOnly = false, // <-- اختياري
  void Function()? onTap,
  bool ispassword = false,
  void Function()? suffixPressed, 
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      readOnly: readOnly,
      onTap: onTap,
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
Widget headingTitle()=> Padding(
  
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.black),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'روز للورود الطبيعية',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.menu, color: Colors.black),
          // ),
        ],
      ),
    );
  Widget _buildListItem(String name, String imageUrl, BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(imageUrl),
      ),
      title: Text(name),
      trailing: GradientButton(
          onPressed: () {}, text: 'إرسال', height: 38, width: 101),
    );
  }
  