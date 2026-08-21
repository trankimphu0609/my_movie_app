import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_strings.dart';
import '../../core/language_controller.dart';
import '../../logic/cubits/theme_cubit.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  String _getLanguageName(String code) {
    switch (code) {
      case 'vi': return 'Tiếng Việt';
      case 'en': return 'English';
      case 'zh': return '中文 (Chinese)';
      case 'ko': return '한국어 (Korean)';
      case 'ja': return '日本語 (Japanese)';
      default: return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = LanguageController.instance.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings', langCode), style: TextStyle(fontWeight: FontWeight.bold)),
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
                title: Text(
                    AppStrings.get('dark_mode', langCode),
                    style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    isDark ? AppStrings.get('enabled', langCode) : AppStrings.get('disabled', langCode),
                    style: TextStyle(color: theme.hintColor),
                ),
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
            title: Text(AppStrings.get('language', langCode), style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              _getLanguageName(langCode),
              style: TextStyle(color: theme.hintColor),
            ),            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),

          const Divider(),

          // Version
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
            title: Text(AppStrings.get('version', langCode), style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('1.0.0'),
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
          title: Text(AppStrings.get('select_language', LanguageController.instance.locale.languageCode)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLangOption(dialogContext, 'vi', 'Tiếng Việt'),
              _buildLangOption(dialogContext, 'en', 'English'),
              _buildLangOption(dialogContext, 'zh', '中文 (Chinese)'),
              _buildLangOption(dialogContext, 'ja', '日本語 (Japanese)'),
              _buildLangOption(dialogContext, 'ko', '한국어 (Korean)'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangOption(BuildContext context, String code, String name) {
    return ListTile(
      title: Text(name),
      leading: Radio<String>(
        value: code,
        groupValue: LanguageController.instance.locale.languageCode,
        onChanged: (val) {
          LanguageController.instance.changeLanguage(code);
          Navigator.pop(context);
          setState(() {});
        },
      ),
      onTap: () {
        LanguageController.instance.changeLanguage(code);
        Navigator.pop(context);
        setState(() {});
      },
    );
  }
}