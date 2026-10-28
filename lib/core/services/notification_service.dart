import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:tasky/core/constants/motivational_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tasky/Models/task_models.dart';

class NotificationService with WidgetsBindingObserver {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String keyMotivationEnabled = 'motivation_enabled';
  static const String _keyMotivationAnchor = 'motivation_anchor';
  // Negative IDs cannot overlap task IDs or existing system notifications.
  static const int _motivationBaseId = -2000;
  static const int _motivationSlots = 12;
  static const Duration motivationInterval = Duration(hours: 2);
  Future<void> _motivationQueue = Future<void>.value();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInitialized) {
      unawaited(_refreshNotifications());
    }
  }

  Future<void> _refreshNotifications() async {
    await _configureLocalTimeZone();
    await scheduleSmartDailyNotifications();
  }

  /// Stable rotation: no repeated message for 2,000 consecutive time slots.
  static String motivationalMessageForSlot(int slot) =>
      motivationalMessages[(slot * 37) % motivationalMessages.length];

  // Preferences keys
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyTaskRemindersEnabled = 'task_reminders_enabled';
  static const String keyMorningBriefingEnabled = 'morning_briefing_enabled';
  static const String keyEveningStreakSaverEnabled =
      'evening_streak_saver_enabled';
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
      await _configureLocalTimeZone();

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
      WidgetsBinding.instance.addObserver(this);
      debugPrint('NotificationService initialized successfully');

      // 4. Request permissions gracefully
      await requestPermissions();

      // 5. Schedule smart recurring notifications if enabled
      await scheduleSmartDailyNotifications();
    } catch (e, stack) {
      debugPrint('NotificationService init error: $e\n$stack');
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (error) {
      // A fixed offset preserves today's wall-clock times if the native lookup
      // fails, rather than silently scheduling daily alerts in UTC.
      final offset = DateTime.now().timeZoneOffset;
      tz.setLocalLocation(
        tz.Location('device_offset', [0], [0], [
          tz.TimeZone(
            offset,
            isDst: false,
            abbreviation: 'Local',
          ),
        ]),
      );
      debugPrint('Using fixed local timezone offset: $error');
    }
  }

  Future<bool> requestPermissions() async {
    bool? granted = false;
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        granted = await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
      } else if (!kIsWeb && Platform.isMacOS) {
        granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      } else if (!kIsWeb && Platform.isIOS) {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
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
      final tz.TZDateTime tzDate = tz.TZDateTime.from(
        scheduledDateTime,
        tz.local,
      );
      final notificationId = taskNotificationBaseId + task.id;

      // Cancel previous notification for this task before setting new one
      await _notificationsPlugin.cancel(id: notificationId);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'tasky_task_reminders',
            'Task Reminders',
            channelDescription:
                'Notifications for task deadlines and reminders',
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

      debugPrint(
        'Scheduled reminder for task "${task.taskName}" at $tzDate (ID: $notificationId)',
      );
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
    await scheduleMotivationalNotifications();
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
        body:
            'Plan your priorities in Tasky and keep your winning streak going strong! 🚀',
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
        body:
            'Review your day, mark completed habits & tasks before bedtime! 🌟',
        hour: eveningHour,
        minute: eveningMinute,
        channelId: 'tasky_streak_saver',
        channelName: 'Streak Saver & Daily Review',
      );
    } else {
      await _notificationsPlugin.cancel(id: idEveningStreakSaver);
    }
  }

  /// Refresh on launch/resume and settings changes. Serialize refreshes so
  /// toggling off cannot race an older refresh and leave alarms behind.
  Future<void> scheduleMotivationalNotifications() {
    _motivationQueue = _motivationQueue.then((_) async {
      if (!_isInitialized) return;
      try {
        final prefs = await SharedPreferences.getInstance();
        for (var i = 0; i < _motivationSlots; i++) {
          await _notificationsPlugin.cancel(id: _motivationBaseId - i);
        }
        if (!(prefs.getBool(keyNotificationsEnabled) ?? true) ||
            !(prefs.getBool(keyMotivationEnabled) ?? true)) {
          await prefs.remove(_keyMotivationAnchor);
          return;
        }

        final now = DateTime.now();
        final anchor =
            prefs.getInt(_keyMotivationAnchor) ?? now.millisecondsSinceEpoch;
        await prefs.setInt(_keyMotivationAnchor, anchor);
        final firstSlot =
            ((now.millisecondsSinceEpoch - anchor) ~/
                motivationInterval.inMilliseconds) +
            1;
        // iOS allows only 64 pending notifications for the whole application.
        // Reserve space for the two daily alerts and prioritize existing tasks.
        final pending = await _notificationsPlugin
            .pendingNotificationRequests();
        final otherCount = pending
            .where(
              (n) => n.id != idMorningBriefing && n.id != idEveningStreakSaver,
            )
            .length;
        final capacity = (62 - otherCount).clamp(0, _motivationSlots);
        if (capacity < 12) {
          debugPrint(
            'Not enough notification slots for motivational reminders',
          );
          return;
        }
        const details = NotificationDetails(
          android: AndroidNotificationDetails(
            'tasky_motivation',
            'رسائل تحفيزية',
            channelDescription: 'رسالة تحفيزية بالعربي كل ساعتين',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        );
        for (var i = 0; i < capacity; i++) {
          final slot = firstSlot + i;
          final date = DateTime.fromMillisecondsSinceEpoch(
            anchor + slot * motivationInterval.inMilliseconds,
          );
          // Twelve daily alarms keep a two-hour cadence without requiring
          // background Dart execution. Resume rotates their message content.
          await _notificationsPlugin.zonedSchedule(
            id: _motivationBaseId - i,
            title: 'دفعة تحفيز من Tasky 🌱',
            body: motivationalMessageForSlot(slot),
            scheduledDate: tz.TZDateTime.from(date, tz.local),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'motivation',
          );
        }
      } catch (error, stack) {
        debugPrint(
          'Motivational notifications scheduling failed: $error\n$stack',
        );
      }
    });
    return _motivationQueue;
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

      debugPrint(
        'Daily notification scheduled at $hour:$minute for $channelName',
      );
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
            channelDescription:
                'Notifications for Pomodoro focus and break sessions',
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
  Future<bool> showTestNotification() async {
    try {
      if (!_isInitialized) await init();
      if (!_isInitialized || !await requestPermissions()) return false;
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
        body:
            'Your smart notifications are fully set up and ready to keep you productive!',
        notificationDetails: platformDetails,
        payload: 'test_notification',
      );
      return true;
    } catch (e) {
      debugPrint('Error showing test notification: $e');
      return false;
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
