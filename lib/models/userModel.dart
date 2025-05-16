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

  final bool isCommercial;
  final String? provider;
  final String? displayName;
  final Timestamp? lastMessageTime;
  final double? latitude;
  final double? longitude;
  final String? locationUrl;


  const Users({
    required this.isCommercial,
    this.provider,
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
      followers: snapshot['followers'] ?? [],
      following: snapshot['following'] ?? [],
      hours: snapshot['hours'] ?? '',
      location: snapshot['location'] ?? '',
      storeNameLower: (snapshot['storeName'] as String).toLowerCase(), // تم تحويل storeName إلى lowercase
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
      storeNameLower: (data['storeName'] as String).toLowerCase(), // تم تحويل storeName إلى lowercase
    );
  }

  get displayNameOrStoreName => storeName; // تم تعديل هذا ليكون displayNameOrStoreName بدل من null.

}
