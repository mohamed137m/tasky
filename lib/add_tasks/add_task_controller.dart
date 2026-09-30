import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';

class AddTaskController extends ChangeNotifier {
  bool isHighPriority = true;
  final TextEditingController taskNameController = TextEditingController();

  final TextEditingController taskDescriptionController =
      TextEditingController();

  final GlobalKey<FormState> key = GlobalKey<FormState>();

  void addTasks(BuildContext context) async {
    if (key.currentState?.validate() ?? false) {
      List<TaskModels> tasks = HiveStorageManger().loadTasks();
      TaskModels models = TaskModels(
        id: tasks.length + 1,
        taskName: taskNameController.text,
        taskDescription: taskDescriptionController.text,
        isHighPriority: isHighPriority,
      );

      tasks.add(models);

      await HiveStorageManger().saveTasks(tasks);
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
    notifyListeners();
  }

  toggle(bool value) {
    isHighPriority = value;
    notifyListeners();
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }
}
