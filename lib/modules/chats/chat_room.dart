import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/models/firebase/firestore.dart';
import 'package:mehra_app/modules/chats/user_profile.dart';
import 'package:mehra_app/modules/homePage/home_screen.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

class ChatRoom extends StatefulWidget {
  final String userId;
  final String userName;
  final String? orderId;
  final String? sharedPostId;
  final String? sharedPostImageUrl;
  final String? sharedPostDescription;

  const ChatRoom({
    Key? key,
    required this.userId,
    required this.userName,
    this.orderId,
    this.sharedPostId,
    this.sharedPostImageUrl,
    this.sharedPostDescription,
  }) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  bool showEmojiPicker = false;
  TextEditingController textEditingController = TextEditingController();
  String currentUserId = '';
  String profileImage = '';
  String status = 'مغلق';
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final record = AudioRecorder();
  bool _isRecording = false;
  bool _isUploadingAudio = false;
  late AudioPlayer audioPlayer;
  bool isSending = false;
  String? currentPlayingUrl;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _showSendButton = false;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  DocumentSnapshot? _editingMessage;
  bool _isEditing = false;
  bool _showCancelEdit = false;
  final Firebase_Firestor _firestoreService = Firebase_Firestor();

  final List<DayInWeek> days = [
    DayInWeek("السبت", dayKey: "monday"),
    DayInWeek("الأحد", dayKey: "sunday"),
    DayInWeek("الاثنين", dayKey: "tuesday"),
    DayInWeek("الثلاثاء", dayKey: "wednesday"),
    DayInWeek("الأربعاء", dayKey: "thursday"),
    DayInWeek("الخميس", dayKey: "friday"),
    DayInWeek("الجمعة", dayKey: "saturday", isSelected: true),
  ];

  final List<String> hours = [
    'من 8 صباحًا إلى 1 ظهرًا',
    'من 1 ظهرًا إلى 8 مساءً',
    'من 8 مساءً إلى منتصف الليل'
  ];

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _fetchCurrentUser();
    _updateStoreStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOrderConfirmation();
      _handleSharedPost();
      _markAllMessagesAsRead();
    });

    textEditingController.addListener(() {
      setState(() {
        _showSendButton = textEditingController.text.isNotEmpty;
      });
    });

    _listenForIncomingMessages();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    audioPlayer.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> _handleSharedPost() async {
    if (widget.sharedPostId == null) return;

    try {
      final timestamp = Timestamp.now();
      final messageId =
          FirebaseFirestore.instance.collection('messages').doc().id;

      await _firestoreService.sendChatMessage(
        receiverId: widget.userId,
        text: textEditingController.text.isNotEmpty
            ? textEditingController.text
            : 'قام بمشاركة منشور معك',
        imageUrl: widget.sharedPostImageUrl,
        timestamp: timestamp,
        isPostMessage: true,
        postId: widget.sharedPostId,
        postDescription: widget.sharedPostDescription,
      );
    } catch (e) {
      _showSnackBar('فشل مشاركة المنشور: ${e.toString()}');
    }
  }

  Future<void> _markAllMessagesAsRead() async {
    final messagesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(widget.userId)
        .collection('messages');

    final snapshot = await messagesRef.where('isRead', isEqualTo: false).get();
    if (snapshot.docs.isNotEmpty) {
      await _markMessagesAsRead(snapshot.docs);
    }
  }

  void _listenForIncomingMessages() {
    final messagesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(widget.userId)
        .collection('messages');

    _messagesSubscription = messagesRef
        .where('receiverId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) {
      _markMessagesAsRead(snapshot.docs);
    });
  }

  Future<void> _markMessagesAsRead(List<QueryDocumentSnapshot> messages) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var message in messages) {
      final data = message.data() as Map<String, dynamic>;
      if (!(data['isRead'] ?? false)) {
        batch.update(message.reference, {'isRead': true});
      }
    }
    await batch.commit();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(widget.userId)
        .update({'unreadCount': 0});
  }

  void _updateStoreStatus() {
    setState(() {
      status = isStoreOpenNow(days, hours) ? 'مفتوح' : 'مغلق';
    });
  }

  bool isStoreOpenNow(List<DayInWeek> days, List<String> hours) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentHour = now.hour;

    int arabicDayIndex;
    switch (currentDay) {
      case 1:
        arabicDayIndex = 2;
        break;
      case 2:
        arabicDayIndex = 3;
        break;
      case 3:
        arabicDayIndex = 4;
        break;
      case 4:
        arabicDayIndex = 5;
        break;
      case 5:
        arabicDayIndex = 6;
        break;
      case 6:
        arabicDayIndex = 0;
        break;
      case 7:
        arabicDayIndex = 1;
        break;
      default:
        arabicDayIndex = 0;
    }

    if (!days[arabicDayIndex].isSelected) return false;

    for (var hourRange in hours) {
      final parts = hourRange.split('إلى');
      if (parts.length != 2) continue;

      try {
        final startPart = parts[0].replaceAll('من', '').trim();
        final endPart = parts[1].trim();

        int startHour = _parseHour(startPart);
        int endHour = _parseHour(endPart);

        if (currentHour >= startHour && currentHour < endHour) return true;
      } catch (e) {
        print('Error parsing hour range: $e');
      }
    }

    return false;
  }

  int _parseHour(String hourStr) {
    if (hourStr.contains('صباحًا')) {
      return int.parse(hourStr.replaceAll('صباحًا', '').trim());
    } else if (hourStr.contains('ظهرًا')) {
      return int.parse(hourStr.replaceAll('ظهرًا', '').trim()) + 12;
    } else if (hourStr.contains('مساءً')) {
      return int.parse(hourStr.replaceAll('مساءً', '').trim()) + 12;
    } else if (hourStr.contains('منتصف الليل')) {
      return 24;
    }
    return int.parse(hourStr);
  }

  void _initAudioPlayer() {
    audioPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..onPlayerStateChanged.listen((state) {
        setState(() => _isPlaying = state == PlayerState.playing);
      })
      ..onDurationChanged.listen((duration) {
        setState(() => _duration = duration);
      })
      ..onPositionChanged.listen((position) {
        setState(() => _position = position);
      });
  }

  Future<void> startRecording() async {
    try {
      if (await record.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await record.start(RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    } catch (e) {
      _showSnackBar('فشل بدء التسجيل: ${e.toString()}');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await record.stop();
      setState(() => _isRecording = false);
      if (path != null) await _uploadAudioFile(path);
    } catch (e) {
      _showSnackBar('فشل إيقاف التسجيل: ${e.toString()}');
    }
  }

  Future<void> _uploadAudioFile(String filePath) async {
    setState(() => _isUploadingAudio = true);
    try {
      final downloadUrl = await _firestoreService.uploadAudioFile(filePath);
      await _sendMessage(audioUrl: downloadUrl);
    } catch (e) {
      _showSnackBar('فشل تحميل الصوت: ${e.toString()}');
    } finally {
      setState(() => _isUploadingAudio = false);
    }
  }

  Future<void> play(String url) async {
    if (currentPlayingUrl == url && _isPlaying) {
      await audioPlayer.pause();
      return;
    }

    if (currentPlayingUrl != url) {
      await audioPlayer.stop();
      setState(() {
        currentPlayingUrl = url;
        _position = Duration.zero;
      });
    }

    try {
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء تشغيل الصوت');
    }
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => currentUserId = user.uid);
      await _fetchUserData(user.uid);
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      final user = await _firestoreService.getUser(UID: userId);
      setState(() => profileImage = user.profileImage ?? '');
    } catch (e) {
      _showSnackBar('فشل تحميل بيانات المستخدم');
    }
  }

  Future<void> _sendMessage(
      {String? imageUrl,
      String? audioUrl,
      String? postId,
      String? postImageUrl,
      String? postDescription}) async {
    if (isSending) return;
    if (textEditingController.text.isEmpty &&
        imageUrl == null &&
        audioUrl == null &&
        postId == null) return;

    setState(() => isSending = true);
    try {
      final timestamp = Timestamp.now();

      await _firestoreService.sendChatMessage(
        receiverId: widget.userId,
        text: textEditingController.text.isNotEmpty
            ? textEditingController.text
            : null,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        timestamp: timestamp,
        isPostMessage: postId != null,
        postId: postId,
        postImageUrl: postImageUrl,
        postDescription: postDescription,
      );
      textEditingController.clear();
      setState(() => _selectedImage = null);
    } catch (e) {
      _showSnackBar('فشل إرسال الرسالة: ${e.toString()}');
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _deleteAllMessages(bool deleteForBoth) async {
    try {
      await _firestoreService.deleteMessages(
          currentUserId, widget.userId, deleteForBoth);
      _showSnackBar('تم حذف الرسائل بنجاح');
    } catch (e) {
      _showSnackBar('فشل حذف الرسائل: ${e.toString()}');
    }
  }

  Future<void> _deleteMessage(
      DocumentSnapshot messageDoc, bool deleteForBoth) async {
    try {
      final data = messageDoc.data() as Map<String, dynamic>;

      await _firestoreService.deleteMessage(
        senderId: data['senderId'],
        receiverId: data['receiverId'],
        messageId: messageDoc.id,
        deleteForBoth: deleteForBoth,
      );

      _showSnackBar('تم حذف الرسالة بنجاح');
    } catch (e) {
      _showSnackBar('فشل حذف الرسالة: ${e.toString()}');
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImage == null) return;
    try {
      final downloadUrl =
          await _firestoreService.uploadChatImage(_selectedImage!);
      await _sendMessage(imageUrl: downloadUrl);
    } catch (e) {
      _showSnackBar('فشل تحميل الصورة: ${e.toString()}');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
        _showImagePreview();
      }
    } catch (e) {
      _showSnackBar('فشل اختيار الصورة: ${e.toString()}');
    }
  }

  void _showImagePreview() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.38,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 10),
            GradientButton(
              width: double.infinity,
              text: 'ارسال',
              onPressed: () {
                uploadImage();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessageOptions(DocumentSnapshot messageDoc) {
    final data = messageDoc.data() as Map<String, dynamic>;
    final isSender = data['senderId'] == currentUserId;
    final hasText = data['text'] != null;
    final hasImage = data['imageUrl'] != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8F9FA),
                Color(0xFFE9ECEF),
              ],
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 24),
              if (hasText && data['text'].length < 30)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    data['text'],
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (isSender)
                    _buildCircleOption(
                      icon: Icons.delete_forever,
                      iconColor: Colors.white,
                      bgColor: Colors.red[400]!,
                      label: 'حذف',
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteMessageOptions(messageDoc);
                      },
                    ),
                  if (hasText)
                    _buildCircleOption(
                      icon: Icons.copy,
                      iconColor: Colors.white,
                      bgColor: Colors.blue[400]!,
                      label: 'نسخ',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: data['text']));
                        _showSnackBar('تم نسخ النص');
                        Navigator.pop(context);
                      },
                    ),
                  _buildCircleOption(
                    icon: Icons.share,
                    iconColor: Colors.white,
                    bgColor: Colors.green[400]!,
                    label: 'مشاركة',
                    onTap: () {
                      if (hasText) Share.share(data['text']);
                      Navigator.pop(context);
                    },
                  ),
                  if (isSender &&
                      hasText) // فقط إذا كان مرسل الرسالة والنص موجود
                    _buildCircleOption(
                      icon: Icons.edit,
                      iconColor: Colors.white,
                      bgColor: MyColor.pinkColor,
                      label: 'تعديل',
                      onTap: () {
                        _editMessage(messageDoc);
                      },
                    ),
                ],
              ),
              SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => Navigator.pop(context),
                  splashColor: MyColor.pinkColor.withOpacity(0.1),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editMessage(DocumentSnapshot messageDoc) {
    final data = messageDoc.data() as Map<String, dynamic>;
    setState(() {
      _editingMessage = messageDoc;
      _isEditing = true;
      _showCancelEdit = true;
      textEditingController.text = data['text'] ?? '';
    });
    Navigator.pop(context); // إغلاق bottom sheet
    FocusScope.of(context).requestFocus(FocusNode()); // إظهار الكيبورد
  }

  // دالة تحديث الرسالة بعد التعديل
  Future<void> _updateMessage() async {
    if (_editingMessage == null || textEditingController.text.isEmpty) return;

    try {
      final data = _editingMessage!.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(data['senderId'])
          .collection('chats')
          .doc(data['receiverId'])
          .collection('messages')
          .doc(_editingMessage!.id)
          .update({
        'text': textEditingController.text,
        'isEdited': true,
        'editedAt': Timestamp.now(),
      });

      // تحديث الرسالة عند المستقبل أيضاً
      await FirebaseFirestore.instance
          .collection('users')
          .doc(data['receiverId'])
          .collection('chats')
          .doc(data['senderId'])
          .collection('messages')
          .doc(_editingMessage!.id)
          .update({
        'text': textEditingController.text,
        'isEdited': true,
        'editedAt': Timestamp.now(),
      });

      setState(() {
        _isEditing = false;
        _showCancelEdit = false;
        _editingMessage = null;
        textEditingController.clear();
      });
    } catch (e) {
      _showSnackBar('فشل تعديل الرسالة: ${e.toString()}');
    }
  }

  // دالة إلغاء التعديل
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _showCancelEdit = false;
      _editingMessage = null;
      textEditingController.clear();
    });
  }

  Widget _buildCircleOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor.withOpacity(0.9),
                  bgColor.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

 void _showDeleteMessageOptions(DocumentSnapshot messageDoc) {
  bool deleteForMe = false;
  bool deleteForBoth = false;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'حذف الرسالة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),

              // Options with checkboxes
              Column(
                children: [
                  // Delete for me option
                  ListTile(
                    leading: Checkbox(
                      value: deleteForMe,
                      onChanged: (value) {
                        setState(() {
                          deleteForMe = value!;
                          if (deleteForMe) deleteForBoth = false;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                    title: Text(
                      'حذف من عندي فقط',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        deleteForMe = !deleteForMe;
                        if (deleteForMe) deleteForBoth = false;
                      });
                    },
                  ),

                  // Delete for both option
                  ListTile(
                    leading: Checkbox(
                      value: deleteForBoth,
                      onChanged: (value) {
                        setState(() {
                          deleteForBoth = value!;
                          if (deleteForBoth) deleteForMe = false;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    title: Text(
                      'حذف من الطرفين',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        deleteForBoth = !deleteForBoth;
                        if (deleteForBoth) deleteForMe = false;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (deleteForMe) {
                          _deleteMessage(messageDoc, false);
                        } else if (deleteForBoth) {
                          _deleteMessage(messageDoc, true);
                        }
                      },
                      child: Text(
                        'موافقة',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
} Widget _buildMessageItem(DocumentSnapshot messageDoc) {
    final data = messageDoc.data() as Map<String, dynamic>;
    final isSender = data['senderId'] == currentUserId;
    final isRead = data['isRead'] ?? false;
    final timestamp = data['timestamp'] as Timestamp?;

    if (timestamp == null) return SizedBox.shrink();

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showMessageOptions(messageDoc);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onLongPress: () {
              HapticFeedback.mediumImpact();
              _showMessageOptions(messageDoc);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment:
                    isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: _buildMessageContent(
                        data, isSender, isRead, _formatTime(timestamp)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final time = timestamp.toDate();
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildOrderMessage(
      Map<String, dynamic> message, bool isSender, bool isRead, String time) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag, color: MyColor.blueColor),
              SizedBox(width: 8),
              Text(
                'طلب منتج',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MyColor.blueColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(message['text'] ?? ''),
          SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

Widget _buildPostMessage(
    Map<String, dynamic> message, bool isSender, bool isRead, String time) {
  return Center(
    child: InkWell(
      onTap: () {
        if (message['postId'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: MyColor.blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, size: 20, color: MyColor.blueColor),
                  SizedBox(width: 8),
                  Text(
                    'تمت مشاركة المنشور',
                    style: TextStyle(
                      color: MyColor.blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (message['postImageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
                child: Image.network(
                  message['postImageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // التعديل هنا: عرض الرسالة المخصصة بدلاً من وصف المنشور
                  Text(
                    message['message'] ?? 'منشور مشارك', // استخدام حقل message بدلاً من postDescription
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  Future<void> _sendOrderConfirmation() async {
    if (widget.orderId == null) return;

    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('orders')
          .doc(widget.orderId!)
          .get();

      if (!orderDoc.exists) return;

      final orderData = orderDoc.data();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final messageId =
          FirebaseFirestore.instance.collection('messages').doc().id;
      final timestamp = FieldValue.serverTimestamp();
      final messageText =
          'تم إنشاء طلب جديد للمنتج: ${orderData?['productDescription']}';

      final messageData = {
        'senderId': currentUserId,
        'receiverId': widget.userId,
        'text': messageText,
        'timestamp': timestamp,
        'isRead': false,
        'isOrderMessage': true,
        'orderId': widget.orderId,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(widget.userId)
          .collection('messages')
          .doc(messageId)
          .set(messageData);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('chats')
          .doc(currentUserId)
          .collection('messages')
          .doc(messageId)
          .set(messageData);

      if (orderData?['productImage'] != null) {
        final imageMessageId =
            FirebaseFirestore.instance.collection('messages').doc().id;
        final imageMessageData = {
          'senderId': currentUserId,
          'receiverId': widget.userId,
          'imageUrl': orderData?['productImage'],
          'timestamp': timestamp,
          'isRead': false,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('chats')
            .doc(widget.userId)
            .collection('messages')
            .doc(imageMessageId)
            .set(imageMessageData);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('chats')
            .doc(currentUserId)
            .collection('messages')
            .doc(imageMessageId)
            .set(imageMessageData);
      }

      await _updateChatHistory(
          currentUserId, widget.userId, messageText, timestamp);
      await _updateChatHistory(
          widget.userId, currentUserId, messageText, timestamp);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'hasMessages': true,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'hasMessages': true,
      });
    } catch (e) {
      print('Error sending order confirmation: $e');
    }
  }

  Future<void> _updateChatHistory(
    String userId,
    String otherUserId,
    String lastMessage,
    FieldValue timestamp,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(otherUserId)
        .set({
      'lastMessage': lastMessage,
      'lastMessageTime': timestamp,
      'unreadCount': FieldValue.increment(1),
      'isLastMessageRead': false,
    }, SetOptions(merge: true));
  }

  Widget _buildMessageContent(
      Map<String, dynamic> message, bool isSender, bool isRead, String time) {
    if (message['isOrderMessage'] == true) {
      return _buildOrderMessage(message, isSender, isRead, time);
    }

    if (message['isPostMessage'] == true) {
      return _buildPostMessage(message, isSender, isRead, time);
    }

    if (message['text'] != null) {
      return BubbleSpecialOne(
        text: "${message['text']}\n$time",
        isSender: isSender,
        color: isSender ? Colors.white : MyColor.blueColor,
        textStyle: TextStyle(
          fontSize: 18,
          color: isSender ? Colors.black : Colors.white,
        ),
        delivered: true,
        seen: isRead,
      );
    } else if (message['imageUrl'] != null) {
      return BubbleNormalImage(
        id: message['imageUrl'],
        isSender: isSender,
        image: Image.network(message['imageUrl'], fit: BoxFit.cover),
        color: isSender ? Colors.white : MyColor.blueColor,
        delivered: true,
        seen: isRead,
      );
    } else if (message['audioUrl'] != null) {
      return _buildAudioMessage(message, isSender, isRead);
    }

    return SizedBox.shrink();
  }

  Widget _buildAudioMessage(
      Map<String, dynamic> message, bool isSender, bool isRead) {
    final audioUrl = message['audioUrl'] as String?;
    final isCurrent = audioUrl != null && currentPlayingUrl == audioUrl;
    final duration = isCurrent ? _duration : Duration(seconds: 30);
    final position = isCurrent ? _position : Duration.zero;

    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        BubbleNormalAudio(
          isSender: isSender,
          color: isSender ? Colors.white : MyColor.blueColor,
          isPlaying: isCurrent && _isPlaying,
          position: position.inSeconds.toDouble(),
          duration: duration.inSeconds.toDouble(),
          delivered: true,
          seen: isRead,
          onPlayPauseButtonClick: () {
            if (audioUrl != null) {
              _toggleAudioPlay(audioUrl);
            }
          },
          onSeekChanged: (value) {
            if (isCurrent) audioPlayer.seek(Duration(seconds: value.toInt()));
          },
        ),
        SizedBox(height: 4),
        Text(
          '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / '
          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            color: isSender ? Colors.grey[600] : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleAudioPlay(String url) async {
    try {
      if (currentPlayingUrl == url && _isPlaying) {
        await audioPlayer.pause();
      } else {
        await play(url);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء التحكم بالصوت');
    }
  }

  void _showDeleteMessagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الرسائل'),
        content: Text('هل تريد حذف جميع الرسائل؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteOptionsDialog();
            },
            child: Text('نعم'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لا'),
          ),
        ],
      ),
    );
  }

  void _showDeleteOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خيارات الحذف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('حذف من عندي فقط'),
              onTap: () {
                Navigator.pop(context);
                _deleteAllMessages(false);
              },
            ),
            ListTile(
              title: Text('حذف من الطرفين'),
              onTap: () {
                Navigator.pop(context);
                _deleteAllMessages(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioRecordButton() {
    if (_isUploadingAudio) {
      return Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return CircleAvatar(
      backgroundColor: Color(0xffA02D87),
      child: IconButton(
        icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
        onPressed: () => _isRecording ? stopRecording() : startRecording(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = isStoreOpenNow(days, hours);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4423B1), Color(0xFF6B2298)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.userName,
                    style: TextStyle(color: Colors.white, fontSize: 24)),
                Text(status,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            SizedBox(width: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : AssetImage('assets/images/5.jpg') as ImageProvider,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(35),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfileScreen(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: _showDeleteMessagesDialog,
          ),
        ],
      ),
    body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => showEmojiPicker = false);
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4423B1), Color(0xFF6B2298)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xffEFEEF0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getChatMessages(currentUserId, widget.userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) 
                        return Center(child: CircularProgressIndicator());

                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) => _buildMessageItem(snapshot.data!.docs[index]),
                      );
                    },
                  ),
                ),
              ),
              
              if (showEmojiPicker)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      textEditingController.text += emoji.emoji;
                    },
                  ),
                ),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Color(0xffEFEEF0),
                height: 100,
                child: Row(
                  children: [
                    if (_showCancelEdit)
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: _cancelEdit,
                      ),
                    
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.emoji_emotions_outlined),
                              onPressed: () => setState(() => showEmojiPicker = !showEmojiPicker),
                            ),
                            IconButton(
                              icon: Icon(Icons.attach_file),
                              onPressed: _pickImage,
                            ),
                            Expanded(
                              child: TextField(
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: _isEditing ? 'تعديل الرسالة...' : 'اكتب رسالة...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                            ),
                            if (_showSendButton || _isEditing)
                              IconButton(
                                icon: Icon(
                                  _isEditing ? Icons.check : Icons.send,
                                  color: Color(0xffA02D87),
                                ),
                                onPressed: () {
                                  if (_isEditing) {
                                    _updateMessage();
                                  } else {
                                    _sendMessage();
                                  }
                                },
                              )
                            else if (!_isUploadingAudio)
                              _buildAudioRecordButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DayInWeek {
  final String name;
  final String dayKey;
  bool isSelected;

  DayInWeek(this.name, {required this.dayKey, this.isSelected = false});
}
