import 'package:flutter/material.dart';
import 'package:mehra_app/models/message_model.dart';

import '../../shared/theme/theme.dart';

class AllChats extends StatelessWidget {
  const AllChats({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 30, bottom: 10, right: 20),
          child: Row(
            children: [
              Text(
                'كل المحادثات',
                style: MyTheme.heading2,
              ),
            ],
          ),
        ),
        ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: allChats.length, // عدد الدردشات
          itemBuilder: (context, index) {
            final allchat = allChats[index];
            return Container(
                margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(
                        allchat.avatar,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          allchat.sender.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          allchat.text,
                          style: const TextStyle(
                            color: Color(0xff514D4D),
                            fontSize: 20,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        allchat.unreadCount == 0
                            ? Icon(
                                Icons.done_all_sharp,
                                color: MyTheme.kUnreadChatBG,
                              )
                            : CircleAvatar(
                                backgroundColor: MyTheme.kUnreadChatBG,
                                radius: 8,
                                child: Text(
                                  allchat.unreadCount.toString(),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                        SizedBox(
                          height: 10,
                        ),
                        Text(allchat.time, style: MyTheme.bodyTextTime)
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
