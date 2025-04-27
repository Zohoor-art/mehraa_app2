import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'العربية'; // تحديد اللغة الافتراضية

  String get selectedLanguage => _selectedLanguage; // للحصول على اللغة الحالية

  void changeLanguage(String language) {
    _selectedLanguage = language; // تغيير اللغة
    notifyListeners(); // إعلام المستمعين بالتغيير
  }
}