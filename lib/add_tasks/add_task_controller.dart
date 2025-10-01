import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/preferences_manager.dart';

class AddTaskController extends ChangeNotifier {
  bool isHighPriority = true;
  final TextEditingController taskNameController = TextEditingController();

  final TextEditingController taskDescriptionController =
      TextEditingController();

  final GlobalKey<FormState> key = GlobalKey<FormState>();

  void addTasks(BuildContext context) async {
    if (key.currentState?.validate() ?? false) {
      final taskJson = PreferencesManager().getString(KeyStorage.tasks);
      List<dynamic> listTasks = [];

      if (taskJson != null) {
        listTasks = jsonDecode(taskJson);
      }
      TaskModels models = TaskModels(
        id: listTasks.length + 1,
        taskName: taskNameController.text,
        taskDescription: taskDescriptionController.text,
        isHighPriority: isHighPriority,
      );

      listTasks.add(models.toJson());

      final taskEncode = jsonEncode(listTasks);
      await PreferencesManager().setString(KeyStorage.tasks, taskEncode);
      Navigator.of(context).pop(true);
    }
    notifyListeners();
  }

  toggle(bool value) {
    isHighPriority = value;
    notifyListeners();
  }
}
