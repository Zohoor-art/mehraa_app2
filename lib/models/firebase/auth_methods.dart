import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/models/firebase/storge.dart';
import 'package:mehra_app/models/userModel.dart  ' as model; // استيراد لتحويل الصورة إلى Base64

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  

  Future<model.Users> getUserDetails() async {
    User currentUser = auth.currentUser!;
    DocumentSnapshot snap =
    await firestore.collection('users').doc(currentUser.uid).get();
    return model.Users.fromSnap(snap);
  }

  // تسجيل مستخدم جديد
  Future<String> signUpUser({
  required String contactNumber,
  required String uid,
  required String days,
  required String description,
  required String email,
  required String hours,
  required List followers,
  required List following,
  required String location,
  required String? profileImage, 
  required String storeName,
  required String password,
  required String workType,
  required Uint8List file,
 
  }) async {
    String res = 'some error occurred';
    try {
      if (email.isNotEmpty   && storeName.isNotEmpty &&  contactNumber.isNotEmpty && days.isNotEmpty && description.isNotEmpty && hours.isNotEmpty 
      && location.isNotEmpty && storeName.isNotEmpty  && workType.isNotEmpty) {
        // تسجيل المستخدم
        UserCredential cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print(cred.user!.uid);
       String profileImage = await StorageMethod().uploadImageToStorage('profiles', file, false);

        model.Users user = model.Users
        (contactNumber: contactNumber, uid: cred.user!.uid,
         days: days, description: description,
          email: email, followers: [],
           following: [], hours: hours,
           profileImage:profileImage,
            location: location, storeName: storeName,
            
             workType: workType);

        await firestore.collection('users').doc(cred.user!.uid).set(user.toJson());

        res = "success";
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-email') {
        res = 'The email is badly formatted';
      } else if (error.code == 'weak-password') {
        res = 'Password should be at least 6 characters';
      }
    } catch (error) {
      res = error.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "please enter all fields";
      }
    } catch (error) {
      res = error.toString();
    }
    return res;
  }
}