import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/constants/motivational_messages.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('contains exactly 2,000 unique, nonempty Arabic messages', () {
    expect(motivationalMessages, hasLength(2000));
    expect(motivationalMessages.toSet(), hasLength(2000));
    for (final message in motivationalMessages) {
      expect(message.trim(), isNotEmpty);
      expect(RegExp(r'[\u0600-\u06FF]').hasMatch(message), isTrue);
      expect(message.length, lessThan(240));
    }
  });

  test('rotation uses every message before repeating', () {
    final cycle = List.generate(
      2000,
      NotificationService.motivationalMessageForSlot,
    );
    expect(cycle.toSet(), hasLength(2000));
    expect(NotificationService.motivationalMessageForSlot(2000), cycle.first);
    expect(NotificationService.motivationInterval, const Duration(hours: 2));
  });

  test(
    'schedules twelve alarms, preserves cadence, and cancels when disabled',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      SharedPreferences.setMockInitialValues({});
      final calls = <MethodCall>[];
      const channel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'pendingNotificationRequests') {
              return <dynamic>[];
            }
            return true;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
      const timezoneChannel = MethodChannel('flutter_timezone');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            timezoneChannel,
            (_) async => 'Africa/Cairo',
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(timezoneChannel, null);
      });
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      final service = NotificationService();
      await service.init();
      expect(tz.local.name, 'Africa/Cairo');
      List<MethodCall> motivationAlarms() => calls
          .where(
            (call) =>
                call.method == 'zonedSchedule' &&
                (call.arguments as Map)['payload'] == 'motivation',
          )
          .toList();
      final alarms = motivationAlarms();
      expect(alarms, hasLength(12));
      final dates = alarms
          .map(
            (call) => DateTime.parse(
              (call.arguments as Map)['scheduledDateTime'] as String,
            ),
          )
          .toList();
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i].difference(dates[i - 1]), const Duration(hours: 2));
      }
      expect(
        alarms.map((call) => (call.arguments as Map)['body']).toSet(),
        hasLength(12),
      );
      calls.clear();
      await service.scheduleMotivationalNotifications();
      expect(
        (motivationAlarms().first.arguments as Map)['scheduledDateTime'],
        (alarms.first.arguments as Map)['scheduledDateTime'],
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(NotificationService.keyMotivationEnabled, false);
      calls.clear();
      await service.scheduleMotivationalNotifications();
      expect(motivationAlarms(), isEmpty);
      expect(calls.where((call) => call.method == 'cancel'), hasLength(12));

      await prefs.setBool(NotificationService.keyMotivationEnabled, true);
      await prefs.setBool(NotificationService.keyNotificationsEnabled, false);
      calls.clear();
      await service.scheduleMotivationalNotifications();
      expect(motivationAlarms(), isEmpty);
      expect(calls.where((call) => call.method == 'cancel'), hasLength(12));
    },
  );
}
