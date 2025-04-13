import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  
  final String uid;
  final String postId;
  final String description;
  final datePublished;
  final String postUrl;
  final String profileImage;
  final likes;
  final String storeName;
  

  const Post({
    
    required this.uid,
    required this.postId,
    required this.description,
    required this.datePublished,
    required this.postUrl,
    required this.likes,
    required this.storeName,
    required this.profileImage, required String videoUrl,
    
   
  });

  Map<String, dynamic> toJson() => {
        
        'uid': uid,
        'postId': postId,
        'descriptionl': description,
        
        'postUrl': postUrl,
        'profileImage': profileImage,
        'datePublished': datePublished,
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
      datePublished: snapshot['datePublished'],
      likes: snapshot['likes'],
      storeName: snapshot['storeName'], videoUrl: '',
      
    );
  }
}