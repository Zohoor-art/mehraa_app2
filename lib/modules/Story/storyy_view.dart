import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

class StoryyView extends StatefulWidget {
  const StoryyView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StoryyView> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<StoryyView> {
  final StoryController controller = StoryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Container(
            height: 500,
            child: StoryView(
              controller: controller,
              storyItems: [
                StoryItem.text(
                  title: "",
                  backgroundColor: const Color.fromARGB(255, 180, 58, 180),
                  roundedTop: true,
                ),
                StoryItem.inlineImage(
                    url: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                    controller: controller,
                    caption: Text(
                      "Image caption",
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.black54,
                        fontSize: 17,
                      ),
                    )),
                StoryItem.inlineImage(
                    url: "https://i.pinimg.com/736x/4c/26/ff/4c26ffa8495c0c631231f1fa2166d5c3.jpg",
                    controller: controller,
                    caption: Text(
                      "Image caption",
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.black54,
                        fontSize: 17,
                      ),
                    ))
              ],
            ),
          ),
          // الجزء العلوي لاسم المستخدم وصورته
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://scontent.fsah1-1.fna.fbcdn.net/v/t1.6435-9/69604457_2546121162148583_4466103811257139200_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=833d8c&_nc_ohc=i5lEiIgnaRYQ7kNvgHbScXA&_nc_oc=AdjiMfZZxVXQLzoe5hHFL5aR2UDkJ7s4MZNtyybtuDjpRyxGpG3INTUlxtvf86lq04o&_nc_zt=23&_nc_ht=scontent.fsah1-1.fna&_nc_gid=AXiI_BPfFHCo2hd6W2B_PGH&oh=00_AYBoU48OrMz-TZsn7WqZxckHCfb65rd3Ob8cEGJ8vldH9g&oe=67EE1C7B'),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'اسم المستخدم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // هنا يمكنك إضافة ما تريده عند الضغط على الأيقونة
                  },
                ),
              ],
            ),
          ),
          // النص في الأسفل لكتابة الرسالة
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'اكتب رسالة',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite, color: Colors.grey),
                          onPressed: () {
                            // هنا يمكنك إضافة ما تريده عند الضغط على الأيقونة
                            print('أيقونة الإعجاب مضغوطة');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.send_outlined, color: Colors.grey),
                          onPressed: () {
                            // هنا يمكنك إضافة ما تريده عند الضغط على الأيقونة
                            print('أيقونة المشاركة مضغوطة');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}