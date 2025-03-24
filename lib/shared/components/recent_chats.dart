import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mehra_app/models/message_model.dart';
import '../../modules/chats/chat_room.dart';
import '../theme/theme.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: recentChats.length, // عدد الدردشات
          itemBuilder: (context, index) {
            final recentChat = recentChats[index];
            return Container(
                margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(
                        recentChat.avatar,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (context) {
                          return ChatRoom(
                            user: recentChat.sender,
                          );
                        }));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            recentChat.sender.name,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            recentChat.text,
                            style: const TextStyle(
                              color: Color(0xff514D4D),
                              fontSize: 20,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        recentChat.unreadCount == 0
                            ? Icon(
                                Icons.done_all_sharp,
                                color: Colors.blueAccent,
                              )
                            : CircleAvatar(
                                backgroundColor: MyTheme.kUnreadChatBG,
                                radius: 8,
                                child: Text(
                                  recentChat.unreadCount.toString(),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                        SizedBox(
                          height: 10,
                        ),
                        Text(recentChat.time, style: MyTheme.bodyTextTime)
                      ],
                    ),
                  ],
                ));
          },
        ),
      ],
    );
  }
}
