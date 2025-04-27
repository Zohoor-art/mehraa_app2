import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/models/firebase/firestore.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'dart:io';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ChatRoom extends StatefulWidget {
  final String userId;
  final String userName;
  final String? orderId;

  const ChatRoom({
    Key? key,
    required this.userId,
    required this.userName,
    this.orderId,
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

  final Firebase_Firestor _firestoreService = Firebase_Firestor();

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _fetchCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOrderConfirmation();
    });
  }

  Future<void> _sendOrderConfirmation() async {
    if (widget.orderId == null) return;

    try {
      // جلب بيانات الطلب
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

      // إنشاء معرف موحد للرسالة
      final messageId = FirebaseFirestore.instance.collection('messages').doc().id;
      final timestamp = FieldValue.serverTimestamp();
      final messageText = 'تم إنشاء طلب جديد للمنتج: ${orderData?['productDescription']}';

      // بيانات الرسالة الأساسية
      final messageData = {
        'senderId': currentUserId,
        'receiverId': widget.userId,
        'text': messageText,
        'timestamp': timestamp,
        'isRead': false,
        'isOrderMessage': true,
        'orderId': widget.orderId,
      };

      // 1. إرسال الرسالة للمرسل (في سجله)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(widget.userId)
          .collection('messages')
          .doc(messageId)
          .set(messageData);

      // 2. إرسال الرسالة للمستقبل (في سجله)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('chats')
          .doc(currentUserId)
          .collection('messages')
          .doc(messageId)
          .set(messageData);

      // 3. إرسال صورة المنتج إذا كانت موجودة (لكلا الطرفين)
      if (orderData?['productImage'] != null) {
        final imageMessageId = FirebaseFirestore.instance.collection('messages').doc().id;
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

      // 4. تحديث سجل المحادثة لكلا الطرفين
      await _updateChatHistory(currentUserId, widget.userId, messageText, timestamp);
      await _updateChatHistory(widget.userId, currentUserId, messageText, timestamp);

      // 5. تحديث حالة وجود رسائل لكلا المستخدمين
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'hasMessages': true,
      });

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
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

  @override
  void dispose() {
    audioPlayer.dispose();
    record.dispose();
    super.dispose();
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

  Future<void> _sendMessage({String? imageUrl, String? audioUrl}) async {
    if (isSending) return;
    if (textEditingController.text.isEmpty &&
        imageUrl == null &&
        audioUrl == null) return;

    setState(() => isSending = true);
    try {
      await _firestoreService.sendChatMessage(
        receiverId: widget.userId,
        text: textEditingController.text.isNotEmpty
            ? textEditingController.text
            : null,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
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

  Future<void> _markMessagesAsRead(List<QueryDocumentSnapshot> messages) async {
    final unreadIds = messages
        .where((m) => m['receiverId'] == currentUserId && !m['isRead'])
        .map((m) => m.id)
        .toList();

    if (unreadIds.isNotEmpty) {
      await _firestoreService.markMessagesAsRead(
          currentUserId, widget.userId, unreadIds);
    }
  }

  Widget _buildMessageItem(DocumentSnapshot messageDoc) {
    final data = messageDoc.data() as Map<String, dynamic>;
    final isSender = data['senderId'] == currentUserId;
    final isRead = data['isRead'] ?? false;
    final timestamp = data['timestamp'] as Timestamp;
    final time = timestamp.toDate();
    final formattedTime =
        "${time.hour}:${time.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: _buildMessageContent(data, isSender, isRead, formattedTime),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMessage(
      Map<String, dynamic> message, bool isSender, bool isRead, String time) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:  Colors.white,
            blurRadius: 2,
            spreadRadius: 2,
            blurStyle: BlurStyle.inner
          )
        ]
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
      Map<String, dynamic> message, bool isSender, bool isRead, String time) {
    if (message['isOrderMessage'] == true) {
      return _buildOrderMessage(message, isSender, isRead, time);
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

  @override
  Widget build(BuildContext context) {
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
            CircleAvatar(
              radius: 35,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : AssetImage('assets/images/5.jpg') as ImageProvider,
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
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                    stream: _firestoreService.getChatMessages(
                        currentUserId, widget.userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());

                      final messages = snapshot.data!.docs;
                      _markMessagesAsRead(messages);

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessageItem(messages[index]),
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
                      setState(() => showEmojiPicker = false);
                    },
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Color(0xffEFEEF0),
                height: 100,
                child: Row(
                  children: [
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
                              onPressed: () => setState(
                                  () => showEmojiPicker = !showEmojiPicker),
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
                                  hintText: 'اكتب رسالة...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                            ),
                            if (textEditingController.text.isEmpty)
                              _buildAudioRecordButton()
                            else
                              IconButton(
                                icon:
                                    Icon(Icons.send, color: Color(0xffA02D87)),
                                onPressed: _sendMessage,
                              )
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
}