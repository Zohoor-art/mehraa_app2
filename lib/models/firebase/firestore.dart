import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/models/userModel.dart';
import 'package:mehra_app/shared/utils/exception.dart';
import 'package:uuid/uuid.dart';

class Firebase_Firestor {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> CreateUser({
    required String contactNumber,
    required String days,
    required String description,
    required String email,
    required String hours,
    required String location,
    String? profileImage,
    required String storeName,
    required String workType,
  }) async {
    await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'contactNumber': contactNumber,
      'uid': _auth.currentUser!.uid,
      'days': days,
      'description': description,
      'email': email,
      'hours': hours,
      'location': location,
      'profileImage': profileImage,
      'storeName': storeName,
      'workType': workType,
    });
    return true;
  }

  Future<Users> getUser({String? UID}) async {
    try {
      final user = await _firebaseFirestore
          .collection('users')
          .doc(UID ?? _auth.currentUser!.uid)
          .get();
      final snapuser = user.data()!;
      return Users.fromSnap(user);
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<bool> CreatePost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    var uid = Uuid().v4();
    DateTime data = DateTime.now();
    Users user = await getUser();
    await _firebaseFirestore.collection('posts').doc(uid).set({
      'postImage': postImage,
      'username': user.storeName,
      'profileImage': user.profileImage,
      'caption': caption,
      'location': location,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data,
    });
    return true;
  }

//   Future<bool> CreateReels({
//     required String video,
//     required String caption,
//   }) async {
//     var uid = Uuid().v4();
//     DateTime data = DateTime.now();
//     Users user = await getUser();
//     await _firebaseFirestore.collection('reels').doc(uid).set({
//       'reelsvideo': video,
//       'username': user.storeName,
//       'profileImage': user.profileImage,
//       'caption': caption,
//       'uid': _auth.currentUser!.uid,
//       'postId': uid,
//       'like': [],
//       'time': data,
//     });
//     return true;
//   }

//   Future<bool> Comments({
//     required String comment,
//     required String type,
//     required String uidd,
//   }) async {
//     var uid = Uuid().v4();
//     Users user = await getUser();
//     await _firebaseFirestore
//         .collection(type)
//         .doc(uidd)
//         .collection('comments')
//         .doc(uid)
//         .set({
//       'comment': comment,
//       'username': user.storeName,
//       'profileImage': user.profileImage,
//       'CommentUid': uid,
//     });
//     return true;
//   }

//   Future<String> like({
//     required List like,
//     required String type,
//     required String uid,
//     required String postId,
//   }) async {
//     String res = 'some error';
//     try {
//       if (like.contains(uid)) {
//         _firebaseFirestore.collection(type).doc(postId).update({
//           'like': FieldValue.arrayRemove([uid]),
//         });
//       } else {
//         _firebaseFirestore.collection(type).doc(postId).update({
//           'like': FieldValue.arrayUnion([uid]),
//         });
//       }
//       res = 'success';
//     } on Exception catch (e) {
//       res = e.toString();
//     }
//     return res;
//   }

//   Future<void> follow({
//     required String uid,
//   }) async {
//     DocumentSnapshot snap = await _firebaseFirestore
//         .collection('users')
//         .doc(_auth.currentUser!.uid)
//         .get();
//     List following = (snap.data()! as dynamic)['following'] ?? [];
//     try {
//       if (following.contains(uid)) {
//         _firebaseFirestore
//             .collection('users')
//             .doc(_auth.currentUser!.uid)
//             .update({
//           'following': FieldValue.arrayRemove([uid]),
//         });
//         await _firebaseFirestore.collection('users').doc(uid).update({
//           'followers': FieldValue.arrayRemove([_auth.currentUser!.uid]),
//         });
//       } else {
//         _firebaseFirestore
//             .collection('users')
//             .doc(_auth.currentUser!.uid)
//             .update({
//           'following': FieldValue.arrayUnion([uid]),
//         });
//         _firebaseFirestore.collection('users').doc(uid).update({
//           'followers': FieldValue.arrayUnion([_auth.currentUser!.uid]),
//         });
//       }
//     } on Exception catch (e) {
//       print(e.toString());
//     }
//   }
// }
}