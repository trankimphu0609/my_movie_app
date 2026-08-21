import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static final LanguageController instance = LanguageController._internal();
  factory LanguageController() => instance;
  LanguageController._internal();

  Locale _locale = const Locale('vi'); // Mặc định là Tiếng Việt
  Locale get locale => _locale;

  // Tải ngôn ngữ đã lưu lần trước khi mở app
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('selected_language') ?? 'vi';
    _locale = Locale(code);
    notifyListeners();
  }

  // Đổi ngôn ngữ và lưu lại
  Future<void> changeLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
  }
}