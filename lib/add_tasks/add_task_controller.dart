import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky/Models/sub_task_model.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/ai_service.dart';
import 'package:tasky/core/services/firestore_sync_service.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/notification_service.dart';

class AddTaskController extends ChangeNotifier {
  bool isHighPriority = false;
  int priority = 2; // 1: Low, 2: Medium, 3: High, 4: Urgent
  String category = 'General';
  DateTime? dueDate;
  TimeOfDay? dueTime;
  List<SubTaskModel> subtasks = [];
  bool isGeneratingAI = false;

  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController subtaskInputController = TextEditingController();

  final GlobalKey<FormState> key = GlobalKey<FormState>();

  void setCategory(String newCategory) {
    category = newCategory;
    notifyListeners();
  }

  void setPriority(int newPriority) {
    priority = newPriority;
    isHighPriority = priority >= 3;
    notifyListeners();
  }

  void setDueDate(DateTime? date) {
    dueDate = date;
    notifyListeners();
  }

  void setDueTime(TimeOfDay? time) {
    dueTime = time;
    notifyListeners();
  }

  void applySmartParseResult(SmartTaskParseResult result) {
    taskNameController.text = result.title;
    if (result.categoryId != null) {
      category = result.categoryId!;
    }
    if (result.priority == 'high') {
      priority = 3;
      isHighPriority = true;
    } else if (result.priority == 'medium') {
      priority = 2;
      isHighPriority = false;
    } else {
      priority = 1;
      isHighPriority = false;
    }
    if (result.dueDate != null) {
      dueDate = result.dueDate;
      dueTime = TimeOfDay.fromDateTime(result.dueDate!);
    }
    notifyListeners();
  }

  void addSubtask(String title) {
    if (title.trim().isEmpty) return;
    subtasks.add(
      SubTaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
      ),
    );
    subtaskInputController.clear();
    notifyListeners();
  }

  void removeSubtask(int index) {
    if (index >= 0 && index < subtasks.length) {
      subtasks.removeAt(index);
      notifyListeners();
    }
  }

  void toggleSubtask(int index) {
    if (index >= 0 && index < subtasks.length) {
      subtasks[index].isDone = !subtasks[index].isDone;
      notifyListeners();
    }
  }

  Future<void> generateSubtasksWithAI(BuildContext context) async {
    final title = taskNameController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task name first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    isGeneratingAI = true;
    notifyListeners();

    try {
      final generated = await AIService().generateSubtasks(
        title,
        taskDescription: taskDescriptionController.text.trim(),
      );

      for (final step in generated) {
        if (!subtasks.any((s) => s.title == step)) {
          subtasks.add(
            SubTaskModel(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  subtasks.length.toString(),
              title: step,
            ),
          );
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🪄 Generated ${generated.length} subtasks successfully!'),
            backgroundColor: const Color(0xFF15B86C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      isGeneratingAI = false;
      notifyListeners();
    }
  }

  void addTasks(BuildContext context) async {
    if (key.currentState?.validate() ?? false) {
      List<TaskModels> tasks = HiveStorageManger().loadTasks();

      String? formattedTime;
      if (dueTime != null) {
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, dueTime!.hour, dueTime!.minute);
        formattedTime = DateFormat('hh:mm a').format(dt);
      }

      TaskModels models = TaskModels(
        id: tasks.isEmpty ? 1 : (tasks.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1),
        taskName: taskNameController.text.trim(),
        taskDescription: taskDescriptionController.text.trim(),
        isHighPriority: priority >= 3,
        priority: priority,
        category: category,
        dueDate: dueDate,
        dueTime: formattedTime,
        rawSubtasks: subtasks.map((s) => s.toMap()).toList(),
        createdAt: DateTime.now(),
      );

      tasks.add(models);

      await HiveStorageManger().saveTasks(tasks);
      FirestoreSyncService().syncToCloud();
      NotificationService().scheduleTaskReminder(models);
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
    notifyListeners();
  }

  void toggle(bool value) {
    isHighPriority = value;
    priority = value ? 3 : 2;
    notifyListeners();
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    subtaskInputController.dispose();
    super.dispose();
  }
}
