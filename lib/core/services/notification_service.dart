import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tasky/Models/task_models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Preferences keys
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyTaskRemindersEnabled = 'task_reminders_enabled';
  static const String keyMorningBriefingEnabled = 'morning_briefing_enabled';
  static const String keyEveningStreakSaverEnabled = 'evening_streak_saver_enabled';
  static const String keyMorningBriefingHour = 'morning_briefing_hour';
  static const String keyMorningBriefingMinute = 'morning_briefing_minute';
  static const String keyEveningStreakHour = 'evening_streak_hour';
  static const String keyEveningStreakMinute = 'evening_streak_minute';

  // Fixed Notification IDs for recurring / system features
  static const int idMorningBriefing = 90001;
  static const int idEveningStreakSaver = 90002;
  static const int idPomodoro = 90003;
  static const int idTestNotification = 90004;
  static const int taskNotificationBaseId = 10000;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Timezones
      tz.initializeTimeZones();
      _configureLocalTimeZone();

      // 2. Android Initialization Settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // 3. iOS Initialization Settings
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');

      // 4. Request permissions gracefully
      await requestPermissions();

      // 5. Schedule smart recurring notifications if enabled
      await scheduleSmartDailyNotifications();
    } catch (e, stack) {
      debugPrint('NotificationService init error: $e\n$stack');
    }
  }

  void _configureLocalTimeZone() {
    try {
      final Duration offset = DateTime.now().timeZoneOffset;
      final locations = tz.timeZoneDatabase.locations;
      for (final entry in locations.entries) {
        if (entry.value.currentTimeZone.offset == offset) {
          tz.setLocalLocation(entry.value);
          return;
        }
      }
    } catch (e) {
      debugPrint('Failed to configure local timezone, falling back to UTC: $e');
    }
  }

  Future<bool> requestPermissions() async {
    bool? granted = false;
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        granted = await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
      } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        final iosImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return granted ?? false;
  }

  // --- Task Due Reminder Scheduling ---

  /// Schedules an exact notification for a task at its specified dueDate and dueTime.
  Future<void> scheduleTaskReminder(TaskModels task) async {
    if (task.isDone || task.dueDate == null) {
      await cancelTaskReminder(task.id);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
    final taskRemindersEnabled = prefs.getBool(keyTaskRemindersEnabled) ?? true;

    if (!notificationsEnabled || !taskRemindersEnabled) {
      return;
    }

    final scheduledDateTime = _parseTaskDateTime(task.dueDate!, task.dueTime);
    if (scheduledDateTime == null) return;

    final now = DateTime.now();
    // Only schedule if in future
    if (!scheduledDateTime.isAfter(now)) {
      return;
    }

    try {
      final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDateTime, tz.local);
      final notificationId = taskNotificationBaseId + task.id;

      // Cancel previous notification for this task before setting new one
      await _notificationsPlugin.cancel(id: notificationId);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'tasky_task_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for task deadlines and reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final String body = task.taskDescription.trim().isNotEmpty
          ? task.taskDescription.trim()
          : 'It is time to conquer this task! Stay focused and productive.';

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: '⏰ Task Reminder: ${task.taskName}',
        body: body,
        scheduledDate: tzDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'task_${task.id}',
      );

      debugPrint('Scheduled reminder for task "${task.taskName}" at $tzDate (ID: $notificationId)');
    } catch (e) {
      debugPrint('Failed to schedule task reminder: $e');
    }
  }

  DateTime? parseTaskDateTime(DateTime date, String? timeStr) =>
      _parseTaskDateTime(date, timeStr);

  DateTime? _parseTaskDateTime(DateTime date, String? timeStr) {
    int hour = 9;
    int minute = 0;

    if (timeStr != null && timeStr.trim().isNotEmpty) {
      try {
        final raw = timeStr.trim().toUpperCase();
        if (raw.contains('AM') || raw.contains('PM')) {
          final isPM = raw.contains('PM');
          final clean = raw.replaceAll('AM', '').replaceAll('PM', '').trim();
          final parts = clean.split(':');
          var h = int.tryParse(parts[0].trim()) ?? 9;
          var m = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;
          if (isPM && h < 12) h += 12;
          if (!isPM && h == 12) h = 0;
          hour = h;
          minute = m;
        } else if (raw.contains(':')) {
          final parts = raw.split(':');
          hour = int.tryParse(parts[0].trim()) ?? 9;
          minute = int.tryParse(parts[1].trim()) ?? 0;
        }
      } catch (e) {
        debugPrint('Error parsing time string "$timeStr": $e');
      }
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<void> cancelTaskReminder(int taskId) async {
    try {
      await _notificationsPlugin.cancel(id: taskNotificationBaseId + taskId);
      debugPrint('Cancelled notification for task ID: $taskId');
    } catch (e) {
      debugPrint('Error cancelling task reminder: $e');
    }
  }

  Future<void> rescheduleAllTasks(List<TaskModels> tasks) async {
    for (final task in tasks) {
      if (!task.isDone && task.dueDate != null) {
        await scheduleTaskReminder(task);
      } else {
        await cancelTaskReminder(task.id);
      }
    }
  }

  // --- Smart Daily Notifications ---

  /// Schedules daily smart notifications: Morning Briefing and Evening Streak Saver.
  Future<void> scheduleSmartDailyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
    if (!notificationsEnabled) {
      await _notificationsPlugin.cancel(id: idMorningBriefing);
      await _notificationsPlugin.cancel(id: idEveningStreakSaver);
      return;
    }

    // 1. Morning Daily Briefing
    final morningEnabled = prefs.getBool(keyMorningBriefingEnabled) ?? true;
    final morningHour = prefs.getInt(keyMorningBriefingHour) ?? 8;
    final morningMinute = prefs.getInt(keyMorningBriefingMinute) ?? 0;

    if (morningEnabled) {
      await _scheduleDailyTimeNotification(
        id: idMorningBriefing,
        title: '☀️ Good Morning! Time to Conquer Today',
        body: 'Plan your priorities in Tasky and keep your winning streak going strong! 🚀',
        hour: morningHour,
        minute: morningMinute,
        channelId: 'tasky_morning_briefing',
        channelName: 'Morning Briefing',
      );
    } else {
      await _notificationsPlugin.cancel(id: idMorningBriefing);
    }

    // 2. Evening Streak Saver
    final eveningEnabled = prefs.getBool(keyEveningStreakSaverEnabled) ?? true;
    final eveningHour = prefs.getInt(keyEveningStreakHour) ?? 20;
    final eveningMinute = prefs.getInt(keyEveningStreakMinute) ?? 30;

    if (eveningEnabled) {
      await _scheduleDailyTimeNotification(
        id: idEveningStreakSaver,
        title: '🔥 Don\'t Break Your Streak!',
        body: 'Review your day, mark completed habits & tasks before bedtime! 🌟',
        hour: eveningHour,
        minute: eveningMinute,
        channelId: 'tasky_streak_saver',
        channelName: 'Streak Saver & Daily Review',
      );
    } else {
      await _notificationsPlugin.cancel(id: idEveningStreakSaver);
    }
  }

  Future<void> _scheduleDailyTimeNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelId,
    required String channelName,
  }) async {
    try {
      await _notificationsPlugin.cancel(id: id);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'smart_$id',
      );

      debugPrint('Daily notification scheduled at $hour:$minute for $channelName');
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
    }
  }

  // --- Instant & Pomodoro Notifications ---

  /// Triggers a notification when a Pomodoro or Break session finishes.
  Future<void> showPomodoroNotification({required bool isBreak}) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
    if (!notificationsEnabled) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'tasky_pomodoro',
        'Pomodoro Focus Timer',
        channelDescription: 'Notifications for Pomodoro focus and break sessions',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final title = isBreak ? '☕ Break Finished!' : '🍅 Pomodoro Finished!';
      final body = isBreak
          ? 'Ready to dive back into deep focus? Let\'s go!'
          : 'Great session! Take a well-deserved short break and stretch.';

      await _notificationsPlugin.show(
        id: idPomodoro,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: 'pomodoro',
      );
    } catch (e) {
      debugPrint('Error showing Pomodoro notification: $e');
    }
  }

  /// Triggers an immediate test notification to verify sounds and banners.
  Future<void> showTestNotification() async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'tasky_test',
        'Test Notifications',
        channelDescription: 'Test notifications channel for Tasky',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id: idTestNotification,
        title: '🔔 Tasky Notifications Active!',
        body: 'Your smart notifications are fully set up and ready to keep you productive!',
        notificationDetails: platformDetails,
        payload: 'test_notification',
      );
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
