import 'package:hive_ce_flutter/hive_flutter.dart';
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
  TaskModels({
    required this.id,
    required this.taskName,
    required this.taskDescription,
    required this.isHighPriority,
    this.isDone = false,
  });
  factory TaskModels.fromJson(Map<String, dynamic> json) {
    return TaskModels(
      id: json["id"],
      taskName: json["taskName"],
      taskDescription: json["taskDescription"],
      isHighPriority: json["isHighPriority"],
      isDone: json["isDone"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "taskName": taskName,
      "taskDescription": taskDescription,
      "isHighPriority": isHighPriority,
      "isDone": isDone,
    };
  }
}
