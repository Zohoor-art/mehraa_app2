import 'package:flutter/material.dart';

import 'package:mehra_app/models/firebase/auth_methods.dart';
import 'package:mehra_app/models/userModel.dart';

class UserProvider with ChangeNotifier {
  Users? _user;
  final AuthMethods authMethods = AuthMethods();
  Users get getUser => _user!;
  Future<void> refreshUser() async {
    Users user = (await authMethods.getUserDetails()) as Users;
    _user = user;
    notifyListeners();
  }
}
