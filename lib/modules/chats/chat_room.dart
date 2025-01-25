import 'package:flutter/material.dart';

import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../shared/theme/theme.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, required this.user});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
  final User user;
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        flexibleSpace: Container(
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
        ),
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  'متصل',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            const SizedBox(width: 20), // إضافة مساحة بين الاسم والصورة
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(widget.user.avatar),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(); // العودة للصفحة السابقة
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 25,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
                size: 35,
                color: Colors.white,
              ))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4423B1), // اللون الأول
                Color(0xFF6B2298), // اللون الثاني
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(0xffEFEEF0),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            bool isMe = message.sender.id == currentUser.id;
                            return Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (!isMe)
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundImage:
                                              AssetImage(widget.user.avatar),
                                        ),
                                      SizedBox(width: 10),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isMe
                                              ? LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Colors.white
                                                  ],
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    Color(0xffA02D87),
                                                    Color(0xff6319A5)
                                                  ],
                                                ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                            bottomLeft:
                                                Radius.circular(isMe ? 12 : 0),
                                            bottomRight:
                                                Radius.circular(isMe ? 0 : 12),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 0,
                                              blurRadius: 9,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          messages[index].text,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            color: isMe
                                                ? Colors.black
                                                : Colors
                                                    .white, // تغيير لون النص
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Row(
                                      mainAxisAlignment: isMe
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        if (!isMe)
                                          SizedBox(
                                            width: 40,
                                          ),
                                        Icon(
                                          Icons.done_all,
                                          size: 20,
                                          color: MyTheme.bodyTextTime.color,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          message.time,
                                          style: MyTheme.bodyTextTime,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ))),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Color(0xffEFEEF0),
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.8),
                                spreadRadius: 0,
                                blurRadius: 9,
                                offset: Offset(0, 3),
                              ),
                            ]),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey[500],
                            ),
                            SizedBox(
                              width: 200,
                            ),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: ' ...اكتب رسالة',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontFamily: 'Tajawal')),
                              ),
                            ),
                            Icon(
                              Icons.attach_file,
                              color: Colors.grey[500],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    CircleAvatar(
                      backgroundColor: Color(0xffA02D87),
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
