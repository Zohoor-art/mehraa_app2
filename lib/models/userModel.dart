// import 'package:cloud_firestore/cloud_firestore.dart';

// class Users {
//   final String? contactNumber;
//   final String uid;
//   final String? days;
//   final String? description;
//   final String? email;
//   final String? hours;
//   final List<dynamic> followers;
//   final List<dynamic> following;
//   final String? location;
//   final String? profileImage;
//   final String? storeName;
//   final String? workType;
//   final bool isCommercial;
//   final String? provider;
//   final String? displayName;
//   final Timestamp? lastMessageTime;

//   const Users({
//     this.contactNumber,
//     required this.uid,
//     this.days,
//     this.description,
//     this.email,
//     this.followers = const [],
//     this.following = const [],
//     this.hours,
//     this.location,
//     this.profileImage,
//     this.storeName,
//     this.workType,
//     this.isCommercial = false,
//     this.provider,
//     this.displayName,
//     this.lastMessageTime,
//   });

//   Map<String, dynamic> toJson() => {
//         'contactNumber': contactNumber,
//         'uid': uid,
//         'days': days,
//         'description': description,
//         'email': email,
//         'followers': followers,
//         'following': following,
//         'hours': hours,
//         'location': location,
//         'profileImage': profileImage,
//         'storeName': storeName,
//         'workType': workType,
//         'isCommercial': isCommercial,
//         'provider': provider,
//         'displayName': displayName,
//         'lastMessageTime': lastMessageTime,
//       };

//   static Users fromSnap(DocumentSnapshot snap) {
//     var snapshot = snap.data() as Map<String, dynamic>;
//     return Users(
//       contactNumber: snapshot['contactNumber'] as String?,
//       uid: snapshot['uid'] as String? ?? '',
//       days: snapshot['days'] as String?,
//       description: snapshot['description'] as String?,
//       email: snapshot['email'] as String?,
//       followers: snapshot['followers'] as List<dynamic>? ?? [],
//       following: snapshot['following'] as List<dynamic>? ?? [],
//       hours: snapshot['hours'] as String?,
//       location: snapshot['location'] as String?,
//       profileImage: snapshot['profileImage'] as String? ?? snapshot['photoURL'] as String?,
//       storeName: snapshot['storeName'] as String?,
//       workType: snapshot['workType'] as String?,
//       isCommercial: snapshot['isCommercial'] as bool? ?? false,
//       provider: snapshot['provider'] as String?,
//       displayName: snapshot['displayName'] as String?,
//       lastMessageTime: snapshot['lastMessageTime'] as Timestamp?,
//     );
//   }

//   String get displayNameOrStoreName {
//     if (isCommercial) return storeName ?? 'متجر بدون اسم';
//     return displayName ?? email?.split('@').first ?? 'مستخدم';
//   }

//   get isOnline => null;
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String contactNumber;
  final String uid;
  final String days;
  final String description;
  final String email;
  final String hours;
  final List followers;
  final List following;
  final String location;
  final String? profileImage; 
  final String storeName;
  final String workType;

  const Users({
    required this.contactNumber,
    required this.uid,
    required this.days,
    required this.description,
    required this.email,
    required this.followers,
    required this.following,
    required this.hours,
    required this.location,
     required this.profileImage,
    required this.storeName,
    required this.workType,
   
  });

  Map<String, dynamic> toJson() => {
        'contactNumber': contactNumber,
        'uid': uid,
        'days': days,
        'description': description,
        'email': email,
        'followers': followers,
        'following': following,
        'hours': hours,
        'location': location,
        'profileImage': profileImage,
        'storeName': storeName,
        'workType': workType,

      };

  static Users fromSnap(DocumentSnapshot snap) {
  var snapshot = snap.data() as Map<String, dynamic>;
  return Users(
    contactNumber: snapshot['contactNumber'] ?? '',
    uid: snapshot['uid'] ?? '',
    days: snapshot['days'] ?? '',
    description: snapshot['description'] ?? '',
    email: snapshot['email'] ?? '',
    followers: snapshot['followers'] ?? [],
    following: snapshot['following'] ?? [],
    hours: snapshot['hours'] ?? '',
    location: snapshot['location'] ?? '',
    profileImage: snapshot['profileImage'] ?? '',
    storeName: snapshot['storeName'] ?? '',
    workType: snapshot['workType'] ?? '',
  );
}
factory Users.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Users(
    contactNumber: data['contactNumber'] ?? '',
    uid: data['uid'] ?? '',
    days: data['days'] ?? '',
    description: data['description'] ?? '',
    email: data['email'] ?? '',
    followers: List.from(data['followers'] ?? []),
    following: List.from(data['following'] ?? []),
    hours: data['hours'] ?? '',
    location: data['location'] ?? '',
    profileImage: data['profileImage'] ?? '', // ✅ هذا أهم سطر
    storeName: data['storeName'] ?? '',
    workType: data['workType'] ?? '',
  );
}


}