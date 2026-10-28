import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/feature/analytics/analytics_screen.dart';
import 'package:tasky/feature/home/home_screen.dart';
import 'package:tasky/feature/pomodoro/pomodoro_screen.dart';
import 'package:tasky/feature/profile/profile_screen.dart';
import 'package:tasky/feature/tasks/tasks_tab_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksTabScreen(),
    PomodoroScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  Widget _buildNavIcon({
    required BuildContext context,
    required int index,
    required IconData icon,
    String? svgPath,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath,
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return Icon(icon, color: color, size: 24);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
            AdService().showInterstitialIfReady();
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.secondary,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              context: context,
              index: 0,
              icon: Icons.home_rounded,
              svgPath: 'assets/image/Home.svg',
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              context: context,
              index: 1,
              icon: Icons.checklist_rounded,
              svgPath: 'assets/image/ToDo.svg',
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              context: context,
              index: 2,
              icon: Icons.timer_outlined,
            ),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              context: context,
              index: 3,
              icon: Icons.bar_chart_rounded,
            ),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              context: context,
              index: 4,
              icon: Icons.person_outline_rounded,
              svgPath: 'assets/image/Profile.svg',
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(child: _screens[_currentIndex]),
    );
  }
}
