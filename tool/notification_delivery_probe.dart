// Run explicitly on a test device:
// flutter run -d <device-id> -t tool/notification_delivery_probe.dart
// Allow notifications, then background the app after PROBE_PENDING is logged.
// Verify the immediate alert and the scheduled alert (15 seconds, subject to
// Android alarm batching). This entry point is never used by the shipping app.
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('Notification delivery test'))),
    ),
  );
  await NotificationService().init();
  final sent = await NotificationService().showTestNotification();
  debugPrint('PROBE_IMMEDIATE=$sent');
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.zonedSchedule(
    id: 90005,
    title: 'اختبار وصول إشعار مجدول',
    body: 'تم وصول الإشعار بعد إغلاق واجهة التطبيق',
    scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 15)),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'tasky_motivation',
        'رسائل تحفيزية',
        importance: Importance.defaultImportance,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: 'delivery_probe',
  );
  final pending = await plugin.pendingNotificationRequests();
  debugPrint('PROBE_PENDING=${pending.map((n) => n.id).toList()}');
}
