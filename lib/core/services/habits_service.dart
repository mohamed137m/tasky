import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/models/habit_item.dart';

class HabitsService {
  static final HabitsService _instance = HabitsService._internal();
  factory HabitsService() => _instance;
  HabitsService._internal();

  static const String _storageKey = 'user_habits_v1';
  final ValueNotifier<List<HabitItem>> habitsNotifier = ValueNotifier([]);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        habitsNotifier.value =
            list.map((m) => HabitItem.fromMap(m as Map<String, dynamic>)).toList();
        return;
      } catch (_) {}
    }

    // Seed default starter habits for fresh users
    habitsNotifier.value = [
      HabitItem(
        id: 'h_water',
        title: 'Drink 2L Water',
        iconKey: 'water',
        colorValue: 0xFF3B82F6,
        completedDates: [],
      ),
      HabitItem(
        id: 'h_read',
        title: 'Read for 20 Mins',
        iconKey: 'book',
        colorValue: 0xFF8B5CF6,
        completedDates: [],
      ),
      HabitItem(
        id: 'h_focus',
        title: 'Deep Work Session',
        iconKey: 'code',
        colorValue: 0xFF15B86C,
        completedDates: [],
      ),
    ];
    await _save();
  }

  Future<void> toggleHabit(String id) async {
    final habits = List<HabitItem>.from(habitsNotifier.value);
    final index = habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      habits[index].toggleToday();
      habitsNotifier.value = habits;
      await _save();
    }
  }

  Future<void> addHabit({
    required String title,
    required String iconKey,
    required int colorValue,
  }) async {
    final newHabit = HabitItem(
      id: 'h_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      iconKey: iconKey,
      colorValue: colorValue,
    );
    final list = List<HabitItem>.from(habitsNotifier.value)..add(newHabit);
    habitsNotifier.value = list;
    await _save();
  }

  Future<void> deleteHabit(String id) async {
    final list = List<HabitItem>.from(habitsNotifier.value)
      ..removeWhere((h) => h.id == id);
    habitsNotifier.value = list;
    await _save();
  }

  /// Calculates completion density for the past [days] days for GitHub Heatmap.
  /// Returns a map of DateTime (midnight) to completion ratio (0.0 to 1.0).
  Map<DateTime, double> getHeatmapData(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final map = <DateTime, double>{};
    final habits = habitsNotifier.value;

    if (habits.isEmpty) return map;

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = HabitItem.dateKey(date);
      int completedCount = 0;
      for (final h in habits) {
        if (h.isCompletedOn(key)) {
          completedCount++;
        }
      }
      map[date] = completedCount / habits.length;
    }

    return map;
  }

  int get totalCompletedToday {
    return habitsNotifier.value.where((h) => h.isCompletedToday).length;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(habitsNotifier.value.map((h) => h.toMap()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
