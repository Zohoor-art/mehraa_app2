import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Post {
  final String userName;
  final String userImage;
  final List<String> images;
  String description;
  bool isFavorited;
  int favoriteCount;
  int shareCount;
  int commentCount;

  Post({
    required this.userName,
    required this.userImage,
    required this.images,
    required this.description,
    this.isFavorited = false,
    this.favoriteCount = 0,
    this.shareCount = 0,
    this.commentCount = 0,
  });
}

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  List<Post> posts = [
    Post(
      userName: 'زهور الجبرني',
      userImage: 'assets/images/3.jpg',
      images: [
        'assets/images/5.jpg',
        'assets/images/6.jpg',
        'assets/images/7.jpg',
      ],
      description: 'هذا هو نص وصف المنشور الذي يضيفه صاحب المنشور.',
    ),
    Post(
      userName: 'أحمد السعيد',
      userImage: 'assets/images/4.jpg',
      images: [
        'assets/images/8.jpg',
        'assets/images/9.jpg',
        'assets/images/10.jpg',
      ],
      description: 'هذا هو نص وصف المنشور الذي يضيفه صاحب المنشور.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Column(
          children: [
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(),
                  boxShadow: [BoxShadow(color: Colors.grey)],
                  image: DecorationImage(
                    image: AssetImage(post.userImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(post.userName),
              subtitle: Text('mmXcksjdfh.sasajhf'),
              trailing: IconButton(
                onPressed: null,
                icon: Icon(Icons.more_vert),
              ),
            ),
            Container(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: post.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        // يمكن إضافة منطق للتغيير في حالة الحاجة
                      });
                    },
                    itemBuilder: (context, imageIndex) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(post.images[imageIndex]),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(post.images.length, (i) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0 ? Colors.purple[800] : Colors.grey, // يمكن تحديث الحالة هنا
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.deepPurple, Colors.pink],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'طلب المنتج',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        post.isFavorited = !post.isFavorited;
                        post.favoriteCount += post.isFavorited ? 1 : -1;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 50,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 206, 212, 225).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          post.isFavorited
                              ? SvgPicture.asset(
                                  'assets/images/fillHeart.svg',
                                  color: Colors.deepPurple,
                                  width: 30,
                                  height: 30,
                                )
                              : SvgPicture.asset(
                                  'assets/images/heartEmp.svg',
                                  color: Colors.deepPurple,
                                  width: 25,
                                  height: 25,
                                ),
                          SizedBox(width: 5),
                          Text(post.favoriteCount.toString()),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        post.shareCount++;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 50,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 206, 212, 225).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/share.svg',
                            color: Colors.deepPurple,
                            width: 28,
                            height: 28,
                          ),
                          SizedBox(width: 5),
                          Text(post.shareCount.toString()),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        post.commentCount++;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 50,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 206, 212, 225).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/comment.svg',
                            color: Colors.deepPurple,
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 5),
                          Text(post.commentCount.toString()),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 80,
                      height: 50,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 206, 212, 225).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/save.svg',
                        color: Colors.deepPurple,
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(),
                      image: DecorationImage(
                        image: AssetImage(post.userImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          post.description,
                          style: TextStyle(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[200],),
          ],
        );
      },
    );
  }
}