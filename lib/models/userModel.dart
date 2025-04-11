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
        'descriptionl': description,
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
      contactNumber: snapshot['contactNumber'],
      uid: snapshot['uid'],
      days: snapshot['days'],
      description: snapshot['description'],
      email: snapshot['email'],
      followers: snapshot['followers'],
      following: snapshot['following'],
      hours: snapshot['hours'],
      location: snapshot['location'],
      profileImage: snapshot['profileImage'],
      storeName: snapshot['storeName'],
      workType: snapshot['workType'], 
    );
  }
}