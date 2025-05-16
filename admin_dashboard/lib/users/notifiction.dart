// import 'package:flutter/material.dart';


// class StoreAdminActions extends StatelessWidget {
//   final String storeId;

//   const StoreAdminActions({super.key, required this.storeId});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ElevatedButton.icon(
//           onPressed: () async {
//             try {
//               // حذف المؤشر ليُرسل التقرير من جديد
//               await WeeklyNotificationManager.forceSendWeeklySummary(storeId);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('✅ تم إرسال التقرير الأسبوعي يدوياً.')),
//               );
//             } catch (e) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('❌ حدث خطأ: $e')),
//               );
//             }
//           },
//           icon: Icon(Icons.refresh),
//           label: Text("تحديث التقرير الأسبوعي"),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
//         ),
//       ],
//     );
//   }
// }
