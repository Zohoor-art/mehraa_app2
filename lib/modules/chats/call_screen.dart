// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;

//   const VideoCallScreen({Key? key, required this.channelName})
//       : super(key: key);

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   late final RtcEngine _engine;
//   final List<int> _users = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAgora();
//   }

//   Future<void> _initializeAgora() async {
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(appId: 'd663d625b4554146b72c70eac88dc32d'));

//     _engine.registerEventHandler(RtcEngineEventHandler(
//       onUserJoined: (RtcConnection connection, int uid, int elapsed) {
//         setState(() {
//           _users.add(uid);
//         });
//       },
//       onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
//         setState(() {
//           _users.remove(uid);
//         });
//       },
//     ));

//     await _engine.joinChannel(
//       token: '1d924319a8b248578eb6e0d546bd0d8d', // استخدم التوكن الأساسي أو الثانوي هنا
//       channelId: widget.channelName,
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }

//   @override
//   void dispose() {
//     _engine.leaveChannel();
//     _engine.release();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 50,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xFF4423B1),
//                 Color(0xFF6B2298),
//               ],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//           ),
//         ),
//         elevation: 0,
//         title: Center(child: const Text('مكالمة فيديو')),
//       ),
//       body: Stack(
//         children: [
//           Center(child: Text('مكالمة نشطة')),
//           for (var uid in _users)
//             Positioned(
//               child: Container(
//                 width: 100,
//                 height: 150,
//                 color: Colors.black,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }