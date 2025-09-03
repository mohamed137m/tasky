class TaskModels {
  int id;
  String taskName;
  String taskDescription;
  bool isHighPriority;
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
