import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static final LanguageController instance = LanguageController._internal();
  factory LanguageController() => instance;
  LanguageController._internal();

  Locale _locale = const Locale('vi');
  Locale get locale => _locale;

  // Danh sách các ngôn ngữ app hỗ trợ
  final List<String> supportedLanguages = ['vi', 'en', 'zh', 'ja', 'ko'];

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('selected_language') ?? 'vi';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) return;
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
  }
}