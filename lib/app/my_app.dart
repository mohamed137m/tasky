import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/core/theme/dark_theme.dart';
import 'package:tasky/core/theme/light_theme.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/feature/navigation/main_screen.dart';
import 'package:tasky/feature/welcome/weclome_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.username, this.isLoggedIn});
  final String? username;
  final bool? isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final bool authenticated =
        isLoggedIn ?? (username != null && username!.isNotEmpty);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, ThemeMode value, Widget? child) {
        return ScreenUtilInit(
          designSize: const Size(375, 809),
          minTextAdapt: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'Tasky',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: value,
              navigatorObservers: [
                AppRouteAdObserver(),
              ],
              home: authenticated ? const MainScreen() : const WelcomeScreen(),
            );
          },
        );
      },
    );
  }
}
