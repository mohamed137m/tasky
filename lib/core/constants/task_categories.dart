import 'package:flutter/material.dart';

class TaskCategory {
  final String id;
  final String nameEn;
  final IconData icon;
  final Color color;

  const TaskCategory({
    required this.id,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  String get name => nameEn;
  String get nameAr => nameEn;

  static const List<TaskCategory> all = [
    TaskCategory(
      id: 'General',
      nameEn: 'General',
      icon: Icons.check_circle_outline,
      color: Color(0xFF15B86C),
    ),
    TaskCategory(
      id: 'Work',
      nameEn: 'Work',
      icon: Icons.work_outline,
      color: Color(0xFF3B82F6),
    ),
    TaskCategory(
      id: 'Personal',
      nameEn: 'Personal',
      icon: Icons.person_outline,
      color: Color(0xFF8B5CF6),
    ),
    TaskCategory(
      id: 'Study',
      nameEn: 'Study',
      icon: Icons.menu_book_outlined,
      color: Color(0xFFEC4899),
    ),
    TaskCategory(
      id: 'Health',
      nameEn: 'Health',
      icon: Icons.fitness_center_outlined,
      color: Color(0xFF10B981),
    ),
    TaskCategory(
      id: 'Finance',
      nameEn: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFFF59E0B),
    ),
  ];

  static TaskCategory fromId(String? id) {
    if (id == null) return all.first;
    return all.firstWhere(
      (c) => c.id.toLowerCase() == id.toLowerCase(),
      orElse: () => all.first,
    );
  }
}
