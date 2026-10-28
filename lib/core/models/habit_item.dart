import 'dart:convert';
import 'package:flutter/material.dart';

class HabitItem {
  final String id;
  final String title;
  final String iconKey;
  final int colorValue;
  final List<String> completedDates; // Format: 'YYYY-MM-DD'

  HabitItem({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.colorValue,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool isCompletedOn(String dateKey) {
    return completedDates.contains(dateKey);
  }

  bool get isCompletedToday => isCompletedOn(todayKey());

  void toggleToday() {
    final today = todayKey();
    if (completedDates.contains(today)) {
      completedDates.remove(today);
    } else {
      completedDates.add(today);
    }
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    int streak = 0;
    var checkDate = DateTime.now();

    // If today is completed, start from today, else start from yesterday
    final today = todayKey();
    if (!completedDates.contains(today)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final key = dateKey(checkDate);
      if (completedDates.contains(key)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  IconData get icon {
    switch (iconKey) {
      case 'water':
        return Icons.water_drop_outlined;
      case 'book':
        return Icons.menu_book_outlined;
      case 'workout':
        return Icons.fitness_center_outlined;
      case 'code':
        return Icons.code_rounded;
      case 'meditate':
        return Icons.self_improvement_rounded;
      case 'journal':
        return Icons.edit_note_rounded;
      case 'walk':
        return Icons.directions_walk_rounded;
      case 'sleep':
        return Icons.bedtime_outlined;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'completedDates': completedDates,
    };
  }

  factory HabitItem.fromMap(Map<String, dynamic> map) {
    return HabitItem(
      id: map['id'] as String? ?? UniqueKey().toString(),
      title: map['title'] as String? ?? 'Habit',
      iconKey: map['iconKey'] as String? ?? 'check',
      colorValue: map['colorValue'] as int? ?? 0xFF15B86C,
      completedDates: (map['completedDates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory HabitItem.fromJson(String source) =>
      HabitItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
