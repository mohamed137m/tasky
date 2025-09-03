import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/feature/tasks/complete_tasks_screen.dart';
import 'package:tasky/feature/home/home_screen.dart';
import 'package:tasky/feature/profile/profile_screen.dart';
import 'package:tasky/feature/tasks/todo_tasks_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  SvgPicture _buildSvgPicture(String urlImage, int index) {
    return SvgPicture.asset(
      urlImage,
      colorFilter: _currentIndex == index
          ? ColorFilter.mode(Color(0xff15B86C), BlendMode.srcIn)
          : ColorFilter.mode(
              ThemeController.isDark() ? Color(0xffC6C6C6) : Color(0xff3A4640),
              BlendMode.srcIn,
            ),
    );
  }

  final List<Widget> _screens = [
    HomeScreen(),
    TodoTasksScreen(),
    CompleteTasksScreen(),
    ProfileScreen(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _buildSvgPicture('assets/image/Home.svg', 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildSvgPicture('assets/image/ToDo.svg', 1),
            label: 'To Do',
          ),
          BottomNavigationBarItem(
            icon: _buildSvgPicture('assets/image/Completed.svg', 2),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: _buildSvgPicture('assets/image/Profile.svg', 3),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(child: _screens[_currentIndex]),
    );
  }
}
