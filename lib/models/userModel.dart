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
  final bool isCommercial;
  final String? provider;
  final String? displayName;
  final Timestamp? lastMessageTime;
  final double? latitude;
  final double? longitude;
  final String? locationUrl;
  final String accountType; // 'commercial', 'google', 'guest'


  const Users({
    required this.isCommercial,
    this.provider,
    required this.accountType,

    this.displayName,
    this.lastMessageTime,
    this.locationUrl,
    this.latitude,
    this.longitude,
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
        'accountType': accountType,

        'profileImage': profileImage,
        'storeName': storeName,
        'workType': workType,
        'latitude': latitude,
        'longitude': longitude,
        'locationUrl': locationUrl,
      };

  static Users fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Users(
      contactNumber: snapshot['contactNumber'] ?? '',
      uid: snapshot['uid'] ?? '',
      days: snapshot['days'] ?? '',
      latitude: snapshot['latitude'] ?? 0.0,
      longitude: snapshot['longitude'] ?? 0.0,
      description: snapshot['description'] ?? '',
      email: snapshot['email'] ?? '',
      accountType: snapshot['accountType'] ?? 'guest',

      followers: snapshot['followers'] ?? [],
      following: snapshot['following'] ?? [],
      hours: snapshot['hours'] ?? '',
      location: snapshot['location'] ?? '',
      locationUrl: snapshot['locationUrl'] ?? '',
      profileImage: snapshot['profileImage'] ?? '',
      storeName: snapshot['storeName'] ?? '',
      workType: snapshot['workType'] ?? '',
      isCommercial: snapshot['isCommercial'] as bool? ?? false,
    );
  }

  factory Users.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Users(
      contactNumber: data['contactNumber'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      uid: data['uid'] ?? '',
      days: data['days'] ?? '',
      description: data['description'] ?? '',
      accountType: data['accountType'] ?? 'guest',

      email: data['email'] ?? '',
      followers: List.from(data['followers'] ?? []),
      following: List.from(data['following'] ?? []),
      hours: data['hours'] ?? '',
      location: data['location'] ?? '',
      locationUrl: data['locationUrl'] ?? '',
      profileImage: data['profileImage'] ?? '', // ✅ هذا أهم سطر
      storeName: data['storeName'] ?? '',
      workType: data['workType'] ?? '', 
      isCommercial: data['isCommercial'] as bool? ?? false,
    );
  }

  get displayNameOrStoreName => null;
}
