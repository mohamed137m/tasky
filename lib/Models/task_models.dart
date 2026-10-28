import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:tasky/Models/sub_task_model.dart';

part 'task_models.g.dart';

@HiveType(typeId: 0)
class TaskModels {
  @HiveField(0)
  int id;

  @HiveField(1)
  String taskName;

  @HiveField(2)
  String taskDescription;

  @HiveField(3)
  bool isHighPriority;

  @HiveField(4)
  bool isDone;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String? dueTime;

  @HiveField(7)
  String category;

  @HiveField(8)
  int priority; // 1: Low, 2: Medium, 3: High, 4: Urgent

  @HiveField(9)
  List<Map<dynamic, dynamic>>? rawSubtasks;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  DateTime? createdAt;

  TaskModels({
    required this.id,
    required this.taskName,
    required this.taskDescription,
    required this.isHighPriority,
    this.isDone = false,
    this.dueDate,
    this.dueTime,
    this.category = 'General',
    this.priority = 2,
    this.rawSubtasks,
    this.completedAt,
    this.createdAt,
  });

  String get taskTitle => taskName;
  bool get highPriority => isHighPriority;

  List<SubTaskModel> get subtasks {
    if (rawSubtasks == null) return [];
    return rawSubtasks!.map((m) => SubTaskModel.fromMap(m)).toList();
  }

  set subtasks(List<SubTaskModel> items) {
    rawSubtasks = items.map((e) => e.toMap()).toList();
  }

  int get completedSubtasksCount =>
      subtasks.where((s) => s.isDone).length;

  double get subtasksProgress =>
      subtasks.isEmpty ? (isDone ? 1.0 : 0.0) : completedSubtasksCount / subtasks.length;

  bool get isOverdue {
    if (isDone || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  factory TaskModels.fromJson(Map<String, dynamic> json) {
    return TaskModels(
      id: json["id"],
      taskName: json["taskName"],
      taskDescription: json["taskDescription"],
      isHighPriority: json["isHighPriority"] ?? false,
      isDone: json["isDone"] ?? false,
      dueDate: json["dueDate"] != null ? DateTime.tryParse(json["dueDate"]) : null,
      dueTime: json["dueTime"],
      category: json["category"] ?? 'General',
      priority: json["priority"] ?? (json["isHighPriority"] == true ? 3 : 2),
      rawSubtasks: (json["subtasks"] as List<dynamic>?)
          ?.map((e) => e as Map<dynamic, dynamic>)
          .toList(),
      completedAt: json["completedAt"] != null
          ? DateTime.tryParse(json["completedAt"])
          : null,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "taskName": taskName,
      "taskDescription": taskDescription,
      "isHighPriority": isHighPriority,
      "isDone": isDone,
      "dueDate": dueDate?.toIso8601String(),
      "dueTime": dueTime,
      "category": category,
      "priority": priority,
      "subtasks": rawSubtasks,
      "completedAt": completedAt?.toIso8601String(),
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}
