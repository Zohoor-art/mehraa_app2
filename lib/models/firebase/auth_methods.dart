import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mehra_app/models/firebase/storge.dart';
import 'package:mehra_app/models/userModel.dart' as model;

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<model.Users> getUserDetails() async {
    User currentUser = auth.currentUser!;
    DocumentSnapshot snap =
        await firestore.collection('users').doc(currentUser.uid).get();
    return model.Users.fromSnap(snap);
  }

  // بدء عملية التسجيل (الجزء الأول)
  Future<Map<String, dynamic>> startSignUpProcess({
  required String email,
  required String password,
  required String storeName,
  required Uint8List file,
}) async {
  try {
    if (email.isEmpty || storeName.isEmpty || password.isEmpty) {
      throw 'الرجاء ملء جميع الحقول المطلوبة';
    }

    // إنشاء مستخدم جديد
    UserCredential cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // إرسال التحقق من البريد الإلكتروني
    await cred.user!.sendEmailVerification();

    // رفع الصورة إلى التخزين
    String profileImage =
        await StorageMethod().uploadImageToStorage('profiles', file, false);

    // تخزين بيانات المستخدم في Firestore
    await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'storeName': storeName,
      'profileImage': profileImage,
      'uid': cred.user!.uid,
      'isCompleted': false, // حقل حالة التسجيل
    });

    return {
      'success': true,
      'userId': cred.user!.uid,
      'profileImage': profileImage,
      'message': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني'
    };
  } on FirebaseAuthException catch (error) {
    String message = 'حدث خطأ ما';
    if (error.code == 'invalid-email') {
      message = 'البريد الإلكتروني غير صالح';
    } else if (error.code == 'weak-password') {
      message = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    } else if (error.code == 'email-already-in-use') {
      message = 'البريد الإلكتروني مستخدم بالفعل';
    }
    return {'success': false, 'message': message};
  } catch (error) {
    return {'success': false, 'message': error.toString()};
  }
}

  // إكمال عملية التسجيل (الجزء الثاني)


Future<String> completeSignUpProcess({
  required String userId,
  required String contactNumber,
  required String days,
  required String description,
  required String email,
  required String hours,
  required String location,
  required String profileImage,
  required String storeName,
   
  required String workType,
  double? latitude,
  double? longitude,
  String? locationUrl,
}) async {
  try {
    User? user = auth.currentUser;
    if (user == null || user.uid != userId) {
      return 'المستخدم غير موجود';
    }

    if (!user.emailVerified) {
      return 'الرجاء التحقق من البريد الإلكتروني أولاً';
    }

    // إنشاء نموذج المستخدم
    model.Users userModel = model.Users(
      contactNumber: contactNumber,
      uid: userId,
      days: days,
      description: description,
      email: email,
      followers: [],
      following: [],
      hours: hours,
      profileImage: profileImage,
      location: location,
      storeName: storeName,
       storeNameLower: storeName.toLowerCase(), 
      workType: workType,
      latitude: latitude,
      longitude: longitude,
      locationUrl: locationUrl, 
      isCommercial: true,
    );

    // رفع البيانات مع إضافة isCompleted
    await firestore.collection('users').doc(userId).set({
      ...userModel.toJson(),
       'storeNameLower': storeName.toLowerCase(),
      'isCompleted': true, // ← إضافة الحقل هنا
    });

    return "success";
  } catch (error) {
    return error.toString();
  }
}


  // تسجيل الدخول
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "الرجاء ملء جميع الحقول";
      }

      UserCredential cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!cred.user!.emailVerified) {
        await auth.signOut();
        return "الرجاء التحقق من بريدك الإلكتروني أولاً";
      }

      return "success";
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found' || error.code == 'wrong-password') {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      return error.toString();
    } catch (error) {
      return error.toString();
    }
  }

  // التحقق من حالة التحقق بالبريد الإلكتروني
  Future<bool> checkEmailVerification(String userId) async {
    User? user = auth.currentUser;
    if (user != null && user.uid == userId) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // البحث عن المستخدمين بناءً على storeNameLower
  Future<List<model.Users>> searchUsersByStoreName(String searchQuery) async {
    try {
      // تحويل الاستعلام إلى حروف صغيرة
      String searchQueryLower = searchQuery.toLowerCase();

      // البحث في مجموعة المستخدمين بناءً على storeNameLower
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .where('storeNameLower', isGreaterThanOrEqualTo: searchQueryLower)
          .where('storeNameLower', isLessThan: searchQueryLower + 'z')
          .get();

      // تحويل النتائج إلى قائمة من المستخدمين
      List<model.Users> usersList = snapshot.docs
          .map((doc) => model.Users.fromSnap(doc))
          .toList();

      return usersList;
    } catch (error) {
      return [];
    }
  }
}
