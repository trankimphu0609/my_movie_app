import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/language_controller.dart';
import '../../logic/cubits/theme_cubit.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLang = LanguageController.instance.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 100), // Chừa khoảng trống tránh bị BottomBar che
        children: [
          // Dark/Light Mode
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return SwitchListTile(
                title: const Text('Giao diện tối (Dark Mode)', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(isDark ? 'Đang bật' : 'Đang tắt', style: TextStyle(color: theme.hintColor)),
                secondary: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.amber : Colors.orange,
                ),
                value: isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),

          const Divider(),

          // Language
          ListTile(
            leading: const Icon(Icons.language, color: Colors.redAccent),
            title: const Text('Ngôn ngữ / Language', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(currentLang == 'vi' ? 'Tiếng Việt' : 'English', style: TextStyle(color: theme.hintColor)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),

          const Divider(),

          // Version
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blueAccent),
            title: Text('Phiên bản ứng dụng', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chọn ngôn ngữ / Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tiếng Việt'),
                leading: Radio<String>(
                  value: 'vi',
                  groupValue: LanguageController.instance.locale.languageCode,
                  onChanged: (val) {
                    LanguageController.instance.changeLanguage('vi');
                    Navigator.pop(dialogContext);
                    setState(() {}); // Load lại màn hình cài đặt để cập nhật text phụ đề
                  },
                ),
                onTap: () {
                  LanguageController.instance.changeLanguage('vi');
                  Navigator.pop(dialogContext);
                  setState(() {});
                },
              ),
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: LanguageController.instance.locale.languageCode,
                  onChanged: (val) {
                    LanguageController.instance.changeLanguage('en');
                    Navigator.pop(dialogContext);
                    setState(() {});
                  },
                ),
                onTap: () {
                  LanguageController.instance.changeLanguage('en');
                  Navigator.pop(dialogContext);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}