import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_movie_app/core/app_strings.dart';
import 'package:my_movie_app/core/language_controller.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'setting_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final GlobalKey<FavoriteScreenState> _favoriteScreenKey = GlobalKey<FavoriteScreenState>();


  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final langCode = LanguageController.instance.locale.languageCode;

    final List<Widget> screens = [
      const HomeScreen(),
      FavoriteScreen(key: _favoriteScreenKey),
      const SettingScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1C1C1E).withOpacity(0.35)
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.movie_outlined,
                        activeIcon: Icons.movie,
                        label: AppStrings.get('home', langCode),
                        isDarkMode: isDarkMode,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.favorite_border,
                        activeIcon: Icons.favorite,
                        label: AppStrings.get('favorite', langCode),
                        isDarkMode: isDarkMode,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings,
                        label: AppStrings.get('settings', langCode),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDarkMode,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);

        if (index == 1) {
          _favoriteScreenKey.currentState?.loadFavorites();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1,
          )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? Colors.redAccent
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[800]),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}