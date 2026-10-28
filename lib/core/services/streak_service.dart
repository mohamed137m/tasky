import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:tasky/core/services/preferences_manager.dart';

class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  static const String _keyCurrentStreak = 'streak_current';
  static const String _keyBestStreak = 'streak_best';
  static const String _keyLastCompletedDate = 'streak_last_date';
  static const String _keyTotalCompleted = 'streak_total_completed';
  static const String _keyTotalXP = 'streak_total_xp';

  static final ValueNotifier<int> streakNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> xpNotifier = ValueNotifier<int>(0);

  void init() {
    streakNotifier.value = currentStreak;
    xpNotifier.value = totalXP;
    _checkStreakLapse();
  }

  int get currentStreak =>
      PreferencesManager().getInt(_keyCurrentStreak) ?? 0;

  int get bestStreak =>
      PreferencesManager().getInt(_keyBestStreak) ?? 0;

  int get totalCompleted =>
      PreferencesManager().getInt(_keyTotalCompleted) ?? 0;

  int get totalXP =>
      PreferencesManager().getInt(_keyTotalXP) ?? 0;

  int get currentLevel => 1 + (totalXP ~/ 50);

  String get levelTitle {
    final lvl = currentLevel;
    if (lvl >= 10) return 'Productivity Master 👑';
    if (lvl >= 7) return 'Task Champion 🏆';
    if (lvl >= 5) return 'Focus Warrior ⚡';
    if (lvl >= 3) return 'Rising Star ⭐';
    return 'Productivity Rookie 🌱';
  }

  /// Called when a user completes a task
  Future<void> recordTaskCompleted() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDate = PreferencesManager().getString(_keyLastCompletedDate);

    int newStreak = currentStreak;

    if (lastDate == null) {
      newStreak = 1;
    } else if (lastDate == today) {
      // Already completed a task today, streak is maintained
    } else {
      final lastDateTime = DateTime.tryParse(lastDate);
      if (lastDateTime != null) {
        final differenceInDays =
            DateTime.now().difference(lastDateTime).inDays;
        if (differenceInDays == 1) {
          newStreak += 1;
        } else if (differenceInDays > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }
    }

    final newBest = newStreak > bestStreak ? newStreak : bestStreak;
    final newTotal = totalCompleted + 1;
    final newXP = totalXP + 10;

    await PreferencesManager().setInt(_keyCurrentStreak, newStreak);
    await PreferencesManager().setInt(_keyBestStreak, newBest);
    await PreferencesManager().setString(_keyLastCompletedDate, today);
    await PreferencesManager().setInt(_keyTotalCompleted, newTotal);
    await PreferencesManager().setInt(_keyTotalXP, newXP);

    streakNotifier.value = newStreak;
    xpNotifier.value = newXP;
  }

  /// Check if the streak was broken due to inactivity
  void _checkStreakLapse() {
    final lastDate = PreferencesManager().getString(_keyLastCompletedDate);
    if (lastDate != null) {
      final lastDateTime = DateTime.tryParse(lastDate);
      if (lastDateTime != null) {
        final differenceInDays =
            DateTime.now().difference(lastDateTime).inDays;
        if (differenceInDays > 1) {
          PreferencesManager().setInt(_keyCurrentStreak, 0);
          streakNotifier.value = 0;
        }
      }
    }
  }
}
