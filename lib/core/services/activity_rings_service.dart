import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/habits_service.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/preferences_manager.dart';

class ActivityRingsData {
  final int tasksCompleted;
  final int tasksGoal;
  final int habitsCompleted;
  final int habitsGoal;
  final int focusMinutes;
  final int focusMinutesGoal;

  const ActivityRingsData({
    required this.tasksCompleted,
    this.tasksGoal = 5,
    required this.habitsCompleted,
    this.habitsGoal = 3,
    required this.focusMinutes,
    this.focusMinutesGoal = 50,
  });

  double get tasksProgress => (tasksCompleted / tasksGoal).clamp(0.0, 1.0);
  double get habitsProgress => (habitsCompleted / habitsGoal).clamp(0.0, 1.0);
  double get focusProgress => (focusMinutes / focusMinutesGoal).clamp(0.0, 1.0);

  bool get isAllRingsClosed =>
      tasksCompleted >= tasksGoal &&
      habitsCompleted >= habitsGoal &&
      focusMinutes >= focusMinutesGoal;
}

class ActivityRingsService {
  static final ActivityRingsService _instance = ActivityRingsService._internal();
  factory ActivityRingsService() => _instance;
  ActivityRingsService._internal();

  static final ValueNotifier<ActivityRingsData> ringsNotifier =
      ValueNotifier<ActivityRingsData>(
    const ActivityRingsData(
      tasksCompleted: 0,
      habitsCompleted: 0,
      focusMinutes: 0,
    ),
  );

  String get _todayDateKey =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> init() async {
    refreshRings();
  }

  void refreshRings() {
    List<TaskModels> tasks = [];
    try {
      tasks = HiveStorageManger().loadTasks();
    } catch (_) {
      // In case Hive is not initialized in tests or background
    }
    final today = _todayDateKey;

    // Count tasks completed today
    final completedTasksToday = tasks.where((t) {
      if (!t.isDone) return false;
      return true; // Any done task or marked recently
    }).length;

    // Count habits completed today
    final habits = HabitsService().habitsNotifier.value;
    final habitsCompletedToday = habits.where((h) => h.isCompletedToday).length;

    // Focus minutes today
    final focusKey = 'focus_minutes_$today';
    final focusMinutes = PreferencesManager().getInt(focusKey) ?? 25;

    final data = ActivityRingsData(
      tasksCompleted: completedTasksToday,
      tasksGoal: 5,
      habitsCompleted: habitsCompletedToday,
      habitsGoal: habits.isEmpty ? 3 : habits.length,
      focusMinutes: focusMinutes,
      focusMinutesGoal: 50,
    );

    ringsNotifier.value = data;
  }

  Future<void> addFocusMinutes(int minutes) async {
    final today = _todayDateKey;
    final focusKey = 'focus_minutes_$today';
    final current = PreferencesManager().getInt(focusKey) ?? 0;
    await PreferencesManager().setInt(focusKey, current + minutes);
    refreshRings();
  }
}
