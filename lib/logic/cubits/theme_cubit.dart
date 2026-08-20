import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'is_dark_mode';

  // Mặc định khởi tạo là Dark Mode
  ThemeCubit() : super(ThemeMode.dark) {
    _loadTheme();
  }

  // Tải trạng thái Theme đã lưu từ SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true; // Mặc định true (Dark)
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  // Chuyển đổi qua lại giữa Dark và Light Mode
  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    emit(newMode);

    // Lưu lựa chọn vào máy
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newMode == ThemeMode.dark);
  }
}