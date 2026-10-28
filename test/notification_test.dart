import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/feature/profile/notification_settings_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Time Parsing & Configuration Tests', () {
    final service = NotificationService();

    test('NotificationService is a singleton', () {
      expect(NotificationService(), same(service));
    });

    test('parseTaskDateTime parses 12-hour AM correctly', () {
      final baseDate = DateTime(2026, 10, 10);
      final result = service.parseTaskDateTime(baseDate, '09:30 AM');
      expect(result, isNotNull);
      expect(result!.year, 2026);
      expect(result.month, 10);
      expect(result.day, 10);
      expect(result.hour, 9);
      expect(result.minute, 30);
    });

    test('parseTaskDateTime parses 12-hour PM correctly', () {
      final baseDate = DateTime(2026, 10, 10);
      final result = service.parseTaskDateTime(baseDate, '02:45 PM');
      expect(result, isNotNull);
      expect(result!.hour, 14);
      expect(result.minute, 45);
    });

    test('parseTaskDateTime parses 12:00 PM and 12:00 AM edge cases', () {
      final baseDate = DateTime(2026, 10, 10);
      final noon = service.parseTaskDateTime(baseDate, '12:00 PM');
      expect(noon!.hour, 12);
      expect(noon.minute, 0);

      final midnight = service.parseTaskDateTime(baseDate, '12:00 AM');
      expect(midnight!.hour, 0);
      expect(midnight.minute, 0);
    });

    test('parseTaskDateTime parses 24-hour time strings correctly', () {
      final baseDate = DateTime(2026, 10, 10);
      final result = service.parseTaskDateTime(baseDate, '17:15');
      expect(result, isNotNull);
      expect(result!.hour, 17);
      expect(result.minute, 15);
    });

    test('parseTaskDateTime defaults to 9:00 AM when time string is null or empty', () {
      final baseDate = DateTime(2026, 10, 10);
      final resultNull = service.parseTaskDateTime(baseDate, null);
      expect(resultNull!.hour, 9);
      expect(resultNull.minute, 0);

      final resultEmpty = service.parseTaskDateTime(baseDate, '   ');
      expect(resultEmpty!.hour, 9);
      expect(resultEmpty.minute, 0);
    });
  });

  group('NotificationSettingsSheet Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        NotificationService.keyNotificationsEnabled: true,
        NotificationService.keyTaskRemindersEnabled: true,
        NotificationService.keyMorningBriefingEnabled: true,
        NotificationService.keyEveningStreakSaverEnabled: true,
        NotificationService.keyMorningBriefingHour: 8,
        NotificationService.keyMorningBriefingMinute: 0,
        NotificationService.keyEveningStreakHour: 20,
        NotificationService.keyEveningStreakMinute: 30,
      });
    });

    testWidgets('NotificationSettingsSheet renders all toggles and actions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationSettingsSheet(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Smart Notifications'), findsOneWidget);
      expect(find.text('Allow Notifications'), findsOneWidget);
      expect(find.text('Task Due Reminders'), findsOneWidget);
      expect(find.text('Morning Briefing'), findsOneWidget);
      expect(find.text('Evening Streak Saver'), findsOneWidget);
      expect(find.text('Send Test Alert'), findsOneWidget);
      expect(find.text('Sync Reminders'), findsOneWidget);
    });
  });
}
