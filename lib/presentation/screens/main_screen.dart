import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../blocs/category/category_cubit.dart';
import '../blocs/stats/stats_cubit.dart';
import '../blocs/theme/theme_cubit.dart';
import 'adhkar/adhkar_categories_screen.dart';
import 'settings/settings_screen.dart';
import 'stats/stats_screen.dart';
import 'tasbeeh/tasbeeh_screen.dart';

/// Root shell screen featuring a 4-tab BottomNavigationBar:
/// 1. الأذكار (Categories Grid)
/// 2. المسبحة (Electronic Tasbeeh)
/// 3. الإحصائيات (Streak & Stats)
/// 4. الإعدادات (Appearance & Preferences)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    AdhkarCategoriesScreen(),
    TasbeehScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Preload categories and stats from SQLite on launch
    context.read<CategoryCubit>().loadCategories();
    context.read<StatsCubit>().loadStats();
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    // Refresh stats when user switches to Stats tab
    if (index == 2) {
      context.read<StatsCubit>().loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titles = ['أَوْرَادُ الْمُسْلِمِ', 'الْمِسْبَحَةُ الإِلِكْتُرُونِيَّةُ', 'إِحْصَائِيَّاتُ الذِّكْرِ', 'الإِعْدَادَاتُ'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          // Quick theme mode toggle button
          IconButton(
            tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
            ),
            onPressed: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              context.read<ThemeCubit>().setThemeMode(newMode);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.album_rounded),
            label: 'المسبحة',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'الإحصائيات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
