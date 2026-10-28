import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasky/app/my_app.dart';
import 'package:tasky/core/services/activity_rings_service.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/core/services/firebase_auth_service.dart';
import 'package:tasky/core/services/firestore_sync_service.dart';
import 'package:tasky/core/services/garden_service.dart';
import 'package:tasky/core/services/habits_service.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/services/streak_service.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  await HiveStorageManger().init();
  await PreferencesManager().init();
  await HabitsService().init();
  await ActivityRingsService().init();
  await GardenService().init();
  await AdService().init();
  await NotificationService().init();
  await ScreenUtil.ensureScreenSize();
  ThemeController().init();
  StreakService().init();
  NotificationService().rescheduleAllTasks(HiveStorageManger().loadTasks());

  final bool isLoggedIn = FirebaseAuthService().isLoggedIn;
  if (isLoggedIn) {
    // Restore or sync data from Cloud Firestore
    await FirestoreSyncService().syncFromCloud();
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}
