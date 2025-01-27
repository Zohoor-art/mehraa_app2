import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/constants.dart';

class XploreScreen extends StatelessWidget {
  const XploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FF),
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
      body: Column(
        children: [
          SizedBox(height: 10), // مسافة فوق الكارد الجديد
          // إضافة أيقونة القائمة والنص في صف واحد
          Container(
            width: MediaQuery.of(context).size.width * 0.9, // 90% من عرض الشاشة
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع العناصر بين اليسار واليمين
              children: [
                Icon(
                  Icons.menu, // أيقونة القائمة
                  size: 30,
                  color: MyColor.blueColor,
                ),
                Text(
                  'اكسبلور',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 12, 12, 12),
                  ),
                  textAlign: TextAlign.right, // محاذاة النص إلى اليمين
                ),
              ],
            ),
          ),
          SizedBox(height: 10), // مسافة تحت النص
          Container(
            width: MediaQuery.of(context).size.width * 0.9, // 90% من عرض الشاشة
            height: 55,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 0),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
              color: Colors.white, // لون الخلفية
              borderRadius: BorderRadius.circular(10), // زوايا مدورة
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // تباعد عن الحواف
                  child: IconButton(
                    icon: Icon(Icons.search, color: MyColor.blueColor),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Text(
                  'بحث',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 12, 12, 12),
                    fontSize: 25,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // تباعد عن الحواف
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: MyColor.blueColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20), // مسافة بين الكارد والأزرار
          // إضافة الأزرار في صف واحد
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // جعل الأزرار قابلة للتمرير أفقيًا
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // توسيط الأزرار
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('الكل'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 20), // تعيين الحجم الأدنى
                    textStyle: TextStyle(fontSize: 18), // حجم النص
                  ),
                ),
                SizedBox(width: 10), // مسافة بين الأزرار
                ElevatedButton(
                  onPressed: () {},
                  child: Text('كيك'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('ورد'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('خياط'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('كوافير'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('كعك'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20), // مسافة بين الأزرار وصور المعرض
          // إضافة GridView لعرض الصور
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // عدد الأعمدة
                crossAxisSpacing: 8.0, // المسافة بين الأعمدة
                mainAxisSpacing: 8.0, // المسافة بين الصفوف
                childAspectRatio: 1, // نسبة عرض إلى ارتفاع الخلايا
              ),
              itemCount: 20, // عدد الصور
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage('https://picsum.photos/200/200?random=$index'), // صورة عشوائية من Picsum
                      fit: BoxFit.cover, // ضبط الصورة لتملأ الحاوية
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}