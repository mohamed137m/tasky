import 'package:flutter/material.dart';
import 'package:tasky/app/my_app.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesManager().init();
  ThemeController().init();
  String? username = PreferencesManager().getString('Username');
  runApp(MyApp(username: username));
}
