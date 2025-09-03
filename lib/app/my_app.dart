import 'package:flutter/material.dart';
import 'package:tasky/core/theme/dark_theme.dart';
import 'package:tasky/core/theme/light_theme.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/feature/navigation/main_screen.dart';
import 'package:tasky/feature/welcome/weclome_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.username});
  final String? username;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, ThemeMode value, Widget? child) {
        return MaterialApp(
          title: 'Tasky',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeController.themeNotifier.value,
          home: username == null ? WelcomeScreen() : MainScreen(),
        );
      },
    );
  }
}
