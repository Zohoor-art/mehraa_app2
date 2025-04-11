import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String postId;
  final String description;
  final DateTime datePublished; // تحديد النوع كـ DateTime
  final String postUrl;
  final String profileImage;
  final List<String> likes; // تحديد النوع كـ List<String>
  final String storeName;

  const Post({
    required this.uid,
    required this.postId,
    required this.description,
    required this.datePublished,
    required this.postUrl,
    required this.likes,
    required this.storeName,
    required this.profileImage,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'postId': postId,
        'description': description,
        'postUrl': postUrl,
        'profileImage': profileImage,
        'datePublished': datePublished.toIso8601String(), // تحويل إلى String
        'likes': likes,
        'storeName': storeName,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      uid: snapshot['uid'],
      postId: snapshot['postId'],
      description: snapshot['description'],
      postUrl: snapshot['postUrl'],
      profileImage: snapshot['profileImage'],
      datePublished: (snapshot['datePublished'] as Timestamp).toDate(), // تحويل Timestamp إلى DateTime
      likes: List<String>.from(snapshot['likes'] ?? []), // تحويل إلى List<String>
      storeName: snapshot['storeName'],
    );
  }
}

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isFavorited = false;

  @override
  Widget build(BuildContext context) {
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
                image: AssetImage(widget.post.profileImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(widget.post.storeName),
          subtitle: Text(widget.post.description),
          trailing: IconButton(
            onPressed: null,
            icon: Icon(Icons.more_vert),
          ),
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(widget.post.postUrl),
            ),
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
                    isFavorited = !isFavorited;
                    // Update favorite count logic if needed
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
                      isFavorited
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
                      Text(widget.post.likes.length.toString()),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Logic for sharing the post
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
                      Text('0'), // عدد المشاركات
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Logic for commenting on the post
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
                      Text('0'), // عدد التعليقات
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Logic for saving the post
                },
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
        Divider(color: Colors.grey[200]),
      ],
    );
  }
}