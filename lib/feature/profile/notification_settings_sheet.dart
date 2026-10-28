import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/core/theme/theme_controller.dart';

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationSettingsSheet(),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  bool _notificationsEnabled = true;
  bool _taskRemindersEnabled = true;
  bool _motivationEnabled = true;
  bool _morningBriefingEnabled = true;
  bool _eveningStreakSaverEnabled = true;

  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 30);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _motivationEnabled =
          prefs.getBool(NotificationService.keyMotivationEnabled) ?? true;
      _notificationsEnabled =
          prefs.getBool(NotificationService.keyNotificationsEnabled) ?? true;
      _taskRemindersEnabled =
          prefs.getBool(NotificationService.keyTaskRemindersEnabled) ?? true;
      _morningBriefingEnabled =
          prefs.getBool(NotificationService.keyMorningBriefingEnabled) ?? true;
      _eveningStreakSaverEnabled =
          prefs.getBool(NotificationService.keyEveningStreakSaverEnabled) ??
          true;

      final mHour =
          prefs.getInt(NotificationService.keyMorningBriefingHour) ?? 8;
      final mMin =
          prefs.getInt(NotificationService.keyMorningBriefingMinute) ?? 0;
      _morningTime = TimeOfDay(hour: mHour, minute: mMin);

      final eHour =
          prefs.getInt(NotificationService.keyEveningStreakHour) ?? 20;
      final eMin =
          prefs.getInt(NotificationService.keyEveningStreakMinute) ?? 30;
      _eveningTime = TimeOfDay(hour: eHour, minute: eMin);

      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
    // Update daily recurring schedules
    await NotificationService().scheduleSmartDailyNotifications();
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark();
    final bgColor = isDark ? const Color(0xFF1E2621) : Colors.white;
    final cardBg = isDark ? const Color(0xFF28342D) : const Color(0xFFF6F8F6);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 250,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF15B86C)),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF15B86C,
                          ).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF15B86C),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Smart Notifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Timely reminders to stay ahead',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Master Toggle Card
                  Material(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _notificationsEnabled
                            ? const Color(0xFF15B86C).withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Allow Notifications',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Master switch for all Tasky alerts',
                          style: TextStyle(fontSize: 12),
                        ),
                        activeThumbColor: const Color(0xFF15B86C),
                        value: _notificationsEnabled,
                        onChanged: (val) async {
                          setState(() => _notificationsEnabled = val);
                          await _saveSetting(
                            NotificationService.keyNotificationsEnabled,
                            val,
                          );
                          if (!val) {
                            await NotificationService().cancelAll();
                          } else {
                            await NotificationService().requestPermissions();
                            final tasks = HiveStorageManger().loadTasks();
                            await NotificationService().rescheduleAllTasks(
                              tasks,
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Individual Settings (Disabled if master is off)
                  Opacity(
                    opacity: _notificationsEnabled ? 1.0 : 0.4,
                    child: IgnorePointer(
                      ignoring: !_notificationsEnabled,
                      child: Column(
                        children: [
                          Material(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            child: SwitchListTile(
                              secondary: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF15B86C),
                              ),
                              title: const Text('رسائل تحفيزية'),
                              subtitle: const Text(
                                '٢٠٠٠ رسالة بالعربي • إشعار كل ساعتين',
                                textDirection: TextDirection.rtl,
                              ),
                              activeThumbColor: const Color(0xFF15B86C),
                              value: _motivationEnabled,
                              onChanged: (value) async {
                                setState(() => _motivationEnabled = value);
                                await _saveSetting(
                                  NotificationService.keyMotivationEnabled,
                                  value,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 1. Task Due Reminders
                          Material(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                secondary: const Icon(
                                  Icons.alarm_rounded,
                                  color: Color(0xFF10B981),
                                ),
                                title: const Text(
                                  'Task Due Reminders',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Exact alerts when scheduled tasks are due',
                                  style: TextStyle(fontSize: 11),
                                ),
                                activeThumbColor: const Color(0xFF15B86C),
                                value: _taskRemindersEnabled,
                                onChanged: (val) async {
                                  setState(() => _taskRemindersEnabled = val);
                                  await _saveSetting(
                                    NotificationService.keyTaskRemindersEnabled,
                                    val,
                                  );
                                  if (!val) {
                                    final tasks = HiveStorageManger()
                                        .loadTasks();
                                    for (final t in tasks) {
                                      await NotificationService()
                                          .cancelTaskReminder(t.id);
                                    }
                                  } else {
                                    final tasks = HiveStorageManger()
                                        .loadTasks();
                                    await NotificationService()
                                        .rescheduleAllTasks(tasks);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 2. Morning Briefing
                          Material(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    secondary: const Icon(
                                      Icons.wb_sunny_rounded,
                                      color: Colors.amber,
                                    ),
                                    title: const Text(
                                      'Morning Briefing',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      'Daily plan summary to kick off your day',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    activeThumbColor: const Color(0xFF15B86C),
                                    value: _morningBriefingEnabled,
                                    onChanged: (val) async {
                                      setState(
                                        () => _morningBriefingEnabled = val,
                                      );
                                      await _saveSetting(
                                        NotificationService
                                            .keyMorningBriefingEnabled,
                                        val,
                                      );
                                    },
                                  ),
                                  if (_morningBriefingEnabled)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Briefing Time:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        TextButton.icon(
                                          onPressed: () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _morningTime,
                                            );
                                            if (picked != null) {
                                              setState(
                                                () => _morningTime = picked,
                                              );
                                              await _saveSetting(
                                                NotificationService
                                                    .keyMorningBriefingHour,
                                                picked.hour,
                                              );
                                              await _saveSetting(
                                                NotificationService
                                                    .keyMorningBriefingMinute,
                                                picked.minute,
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.access_time_rounded,
                                            size: 16,
                                            color: Color(0xFF15B86C),
                                          ),
                                          label: Text(
                                            _formatTime(_morningTime),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF15B86C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3. Evening Streak Saver
                          Material(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    secondary: const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                    title: const Text(
                                      'Evening Streak Saver',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      'Alert before midnight to keep streak alive',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    activeThumbColor: const Color(0xFF15B86C),
                                    value: _eveningStreakSaverEnabled,
                                    onChanged: (val) async {
                                      setState(
                                        () => _eveningStreakSaverEnabled = val,
                                      );
                                      await _saveSetting(
                                        NotificationService
                                            .keyEveningStreakSaverEnabled,
                                        val,
                                      );
                                    },
                                  ),
                                  if (_eveningStreakSaverEnabled)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Reminder Time:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        TextButton.icon(
                                          onPressed: () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _eveningTime,
                                            );
                                            if (picked != null) {
                                              setState(
                                                () => _eveningTime = picked,
                                              );
                                              await _saveSetting(
                                                NotificationService
                                                    .keyEveningStreakHour,
                                                picked.hour,
                                              );
                                              await _saveSetting(
                                                NotificationService
                                                    .keyEveningStreakMinute,
                                                picked.minute,
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.access_time_rounded,
                                            size: 16,
                                            color: Color(0xFF15B86C),
                                          ),
                                          label: Text(
                                            _formatTime(_eveningTime),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF15B86C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final sent = await NotificationService()
                                .showTestNotification();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    sent
                                        ? '🔔 تم إرسال إشعار التجربة. راجع شريط الإشعارات.'
                                        : 'تعذر إرسال الإشعار. فعّل إذن الإشعارات من إعدادات الجهاز.',
                                  ),
                                  backgroundColor: Color(0xFF15B86C),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Send Test Alert',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final tasks = HiveStorageManger().loadTasks();
                            await NotificationService().rescheduleAllTasks(
                              tasks,
                            );
                            await NotificationService()
                                .scheduleSmartDailyNotifications();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '✅ All task reminders synchronized!',
                                  ),
                                  backgroundColor: Color(0xFF15B86C),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.sync_rounded, size: 18),
                          label: const Text(
                            'Sync Reminders',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15B86C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
