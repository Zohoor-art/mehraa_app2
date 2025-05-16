// import 'package:flutter/material.dart';
// import 'package:mehra_app/modules/site/region_stores_screen.dart';
// import 'package:mehra_app/shared/components/constants.dart';

// class SiteScreen extends StatefulWidget {
//   const SiteScreen({super.key});

//   @override
//   State<SiteScreen> createState() => _SiteScreenState();
// }

// class _SiteScreenState extends State<SiteScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColor.lightprimaryColor,
//       appBar: AppBar(
//         toolbarHeight: 0,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [MyColor.blueColor, MyColor.purpleColor],
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'اختر طريقة تحديد الموقع',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF707070),
//               ),
//             ),
//             const SizedBox(height: 40),

//             // زر 1 - دخول لاكتشاف المتاجر
//             _buildButton(
//               title: 'دخول لاكتشاف المتاجر',
//               onTap: () {
//                 Navigator.pushNamed(context, '/search');
//               },
//             ),

//             const SizedBox(height: 20),

//             // زر 2 - حسب المنطقة (location)
//             _buildButton(
//               title: 'اختيار المتجر حسب المنطقة',
//               onTap: () {
//                 Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => const RegionStoresScreen()),
// );

// },

              
//             ),

//             const SizedBox(height: 20),

//             // زر 3 - حسب العنوان المفصل (locationUrl)
//             _buildButton(
//               title: 'البحث بالموقع المفصل',
//               onTap: () {
//                 Navigator.pushNamed(context, '/detailedAddressStores');
//               },
//             ),

//             const SizedBox(height: 20),

//             // زر 4 - تحديد الموقع تلقائياً
//             _buildButton(
//               title: 'تحديد الموقع تلقائياً',
//               onTap: () {
//                 Navigator.pushNamed(context, '/autoLocation');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildButton({required String title, required VoidCallback onTap}) {
//     return ElevatedButton(
//       onPressed: onTap,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: MyColor.blueColor,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         textStyle: const TextStyle(fontSize: 20, fontFamily: 'Tajawal'),
//       ),
//       child: Text(title),
//     );
//   }
// }
