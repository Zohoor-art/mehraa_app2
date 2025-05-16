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
  final String storeNameLower; // تم إضافة هذه الخاصية

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
    required this.storeNameLower, // تم إضافة هذه الخاصية في الـ constructor
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
        'storeNameLower': storeNameLower, // تم إضافة هذه الخاصية في الـ Map
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
      storeNameLower: (snapshot['storeName'] as String).toLowerCase(), // تم تحويل storeName إلى lowercase
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
      storeNameLower: (data['storeName'] as String).toLowerCase(), // تم تحويل storeName إلى lowercase
    );
  }

  get displayNameOrStoreName => storeName; // تم تعديل هذا ليكون displayNameOrStoreName بدل من null.
}
