import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/theme_cubit.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
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
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
            title: const Text('Phiên bản ứng dụng', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}