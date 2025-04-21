import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'dart:io';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatRoom({Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  bool showEmojiPicker = false;
  TextEditingController textEditingController = TextEditingController();
  String currentUserId = '';
  String profileImage = '';
  String status = 'مغلق';
  bool isOpen = true;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final record = AudioRecorder();
  bool _isRecording = false;
  bool _isUploadingAudio = false;
  late AudioPlayer audioPlayer;
  bool isSending = false;
  // متغيرات إدارة حالة الصوت
  String? currentPlayingUrl;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _fetchCurrentUser();
  }

  void _initAudioPlayer() {
    audioPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      })
      ..onDurationChanged.listen((duration) {
        setState(() {
          _duration = duration;
        });
      })
      ..onPositionChanged.listen((position) {
        setState(() {
          _position = position;
        });
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
        final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await record.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        
        setState(() {
          _isRecording = true;
        });
      } else {
        throw Exception('لا يوجد إذن لتسجيل الصوت');
      }
    } catch (e) {
      print('فشل بدء التسجيل: $e');
      _showSnackBar('فشل بدء التسجيل: ${e.toString()}');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await record.stop();
      setState(() {
        _isRecording = false;
      });
      
      if (path != null) {
        await _uploadAudioFile(path);
      }
    } catch (e) {
      print('فشل إيقاف التسجيل: $e');
      _showSnackBar('فشل إيقاف التسجيل: ${e.toString()}');
    }
  }

  Future<void> _uploadAudioFile(String filePath) async {
    setState(() {
      _isUploadingAudio = true;
    });
    
    try {
      final file = File(filePath);
      final fileSize = await file.length();
      
      if (fileSize == 0) {
        throw Exception('الملف الصوتي فارغ');
      }
      
      final ref = FirebaseStorage.instance.ref()
        .child('voices')
        .child('${Uuid().v1()}.m4a');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      await _sendMessage(audioUrl: downloadUrl);
    } catch (e) {
      print('فشل تحميل الصوت: $e');
      _showSnackBar('فشل تحميل الصوت: ${e.toString()}');
    } finally {
      setState(() {
        _isUploadingAudio = false;
      });
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
      print('حدث خطأ أثناء تشغيل الصوت: $e');
      _showSnackBar('حدث خطأ أثناء تشغيل الصوت');
    }
  }

  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      await _fetchUserData(user.uid);
    }
  }

  Future<void> _fetchUserData(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        profileImage = userDoc['profileImage'] ?? '';
      });
    }
  }

  Future<void> _sendMessage({String? imageUrl, String? audioUrl}) async {
    if (isSending) return;
    if (textEditingController.text.isNotEmpty || imageUrl != null || audioUrl != null) {
      setState(() {
        isSending = true;
      });

      String messageId = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(widget.userId)
          .collection('messages')
          .doc()
          .id;

      Map<String, dynamic> messageData = {
        'senderId': currentUserId,
        'receiverId': widget.userId,
        'text': textEditingController.text.isNotEmpty ? textEditingController.text : null,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      try {
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
      } catch (e) {
        _showSnackBar('فشل إرسال الرسالة: ${e.toString()}');
      } finally {
        textEditingController.clear();
        setState(() {
          _selectedImage = null;
          isSending = false;
        });
      }
    }
  }

  Future<void> _deleteAllMessages(bool deleteForBoth) async {
    try {
      // حذف الرسائل من عند المستخدم الحالي
      final currentUserMessages = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(widget.userId)
          .collection('messages')
          .get();

      final batch1 = FirebaseFirestore.instance.batch();
      for (var doc in currentUserMessages.docs) {
        batch1.delete(doc.reference);
      }
      await batch1.commit();

      // إذا تم اختيار حذف الرسائل من الطرفين
      if (deleteForBoth) {
        final otherUserMessages = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('chats')
            .doc(currentUserId)
            .collection('messages')
            .get();

        final batch2 = FirebaseFirestore.instance.batch();
        for (var doc in otherUserMessages.docs) {
          batch2.delete(doc.reference);
        }
        await batch2.commit();
      }

      _showSnackBar('تم حذف الرسائل بنجاح');
    } catch (e) {
      _showSnackBar('فشل حذف الرسائل: ${e.toString()}');
    }
  }

  void _showDeleteMessagesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  void _showDeleteOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  Future<void> uploadImage() async {
    if (_selectedImage != null) {
      try {
        final ref = FirebaseStorage.instance.ref('chats_images/${Uuid().v1()}.jpg');
        await ref.putFile(_selectedImage!);
        String downloadUrl = await ref.getDownloadURL();
        await _sendMessage(imageUrl: downloadUrl);
      } catch (e) {
        _showSnackBar('فشل تحميل الصورة: ${e.toString()}');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _showImagePreview();
      }
    } catch (e) {
      _showSnackBar('فشل اختيار الصورة: ${e.toString()}');
    }
  }

  void _showImagePreview() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.38,
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
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
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _markMessagesAsRead(List<QueryDocumentSnapshot> messages) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (final message in messages) {
        if (message['receiverId'] == currentUserId && !message['isRead']) {
          final messageRef1 = FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('chats')
              .doc(widget.userId)
              .collection('messages')
              .doc(message.id);
              
          final messageRef2 = FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('chats')
              .doc(currentUserId)
              .collection('messages')
              .doc(message.id);
              
          batch.update(messageRef1, {'isRead': true});
          batch.update(messageRef2, {'isRead': true});
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('حدث خطأ أثناء تحديث حالة القراءة: $e');
    }
  }

  Widget _buildMessageItem(QueryDocumentSnapshot message) {
    final isSender = message['senderId'] == currentUserId;
    final isRead = message['isRead'] ?? false;
    final timestamp = message['timestamp'] as Timestamp? ?? Timestamp.now();
    final messageTime = timestamp.toDate();
    final formattedTime = "${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [ 
                _buildMessageContent(message, isSender, isRead, formattedTime),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(QueryDocumentSnapshot message, bool isSender, bool isRead, String time) {
    if (message['text'] != null && message['text'].isNotEmpty) {
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
    }
    else if (message['imageUrl'] != null && message['imageUrl'].isNotEmpty) {
      return BubbleNormalImage(
        id: message['imageUrl'],
        isSender: isSender,
        image: Image.network(message['imageUrl'], fit: BoxFit.cover),
        color: isSender ? Colors.white : MyColor.blueColor,
        delivered: true,
        seen: isRead,
      );
    }
    else if (message['audioUrl'] != null && message['audioUrl'].isNotEmpty) {
      return _buildAudioMessage(message, isSender, isRead);
    }
    
    return SizedBox.shrink();
  }

  Widget _buildAudioMessage(QueryDocumentSnapshot message, bool isSender, bool isRead) {
    final isCurrentPlaying = currentPlayingUrl == message['audioUrl'];
    final duration = isCurrentPlaying ? _duration : Duration(seconds: 30);
    final position = isCurrentPlaying ? _position : Duration.zero;

    return Column(
      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        BubbleNormalAudio(
          isSender: isSender,
          color: isSender ? Colors.white : MyColor.blueColor,
          isPlaying: isCurrentPlaying && _isPlaying,
          position: position.inSeconds.toDouble(),
          duration: duration.inSeconds.toDouble(),
          delivered: true,
          seen: isRead,
          onPlayPauseButtonClick: () => _toggleAudioPlay(message['audioUrl']),
          onSeekChanged: (double value) {
            if (isCurrentPlaying) {
              audioPlayer.seek(Duration(seconds: value.toInt()));
            }
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
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            const SizedBox(width: 20),
            CircleAvatar(
              radius: 35,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : AssetImage('assets/images/5.jpg') as ImageProvider,
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 25, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: Colors.white, size: 30),
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .collection('chats')
                        .doc(currentUserId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      
                      final messages = snapshot.data!.docs;
                      _markMessagesAsRead(messages);
                      
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageItem(messages[index]);
                        },
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
                              icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[500]),
                              onPressed: () => setState(() => showEmojiPicker = !showEmojiPicker),
                            ),
                            IconButton(
                              icon: Icon(Icons.attach_file, color: Colors.grey[500]),
                              onPressed: _pickImage,
                            ),
                            Expanded(
                              child: TextField(
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'اكتب رسالة...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ),
                            ),
                            if (textEditingController.text.isEmpty)
                              _buildAudioRecordButton()
                            else
                              IconButton(
                                icon: Icon(Icons.send, color: Color(0xffA02D87)),
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
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: Color(0xffA02D87),
      child: IconButton(
        icon: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
        ),
        onPressed: () {
          if (_isRecording) {
            stopRecording();
          } else {
            startRecording();
          }
        },
      ),
    );
  }
}