import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasky/app/my_app.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorageManger().init();
  await PreferencesManager().init();
  await ScreenUtil.ensureScreenSize();
  ThemeController().init();
  String? username = PreferencesManager().getString(KeyStorage.username);
  runApp(MyApp(username: username));
}
