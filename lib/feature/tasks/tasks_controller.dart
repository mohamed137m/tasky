import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/preferences_manager.dart';

class TasksController extends ChangeNotifier {
  bool isLoading = false;
  int tootleTask = 0;
  int tootleDoneTask = 0;
  double percent = 0;
  List<TaskModels> tasks = [];
  List<TaskModels> completeTask = [];
  List<TaskModels> toDoTasks = [];
  List<TaskModels> highPriorityTasks = [];

  void init() {
    _loadTaskData();
  }

  doneTask(bool? value, int? index) async {
    if (index == null) return;
    toDoTasks[index].isDone = value ?? false;

    final newIndex = tasks.indexWhere((e) => e.id == toDoTasks[index].id);

    tasks[newIndex] = toDoTasks[index];
    PreferencesManager().setString('tasks', jsonEncode(tasks));

    _loadTaskData();
    notifyListeners();
  }

  doneCompleteTaskTask(bool? value, int? index) async {
    if (index == null) return;
    completeTask[index].isDone = value ?? false;

    final newIndex = tasks.indexWhere((e) => e.id == completeTask[index].id);

    tasks[newIndex] = completeTask[index];
    PreferencesManager().setString(KeyStorage.tasks, jsonEncode(tasks));

    _loadTaskData();
    notifyListeners();
  }

  doneHighPriorityTaskTask(bool? value, int? index) async {
    if (index == null) return;
    highPriorityTasks[index].isDone = value ?? false;

    final newIndex = tasks.indexWhere((e) => e.id == highPriorityTasks[index].id);

    tasks[newIndex] = highPriorityTasks[index];
    PreferencesManager().setString(KeyStorage.tasks, jsonEncode(tasks));

    _loadTaskData();
    notifyListeners();
  }

  void _loadTaskData() {
    isLoading = true;
    final finalTask = PreferencesManager().getString(KeyStorage.tasks);
    if (finalTask != null) {
      final taskAfterDecode = jsonDecode(finalTask) as List<dynamic>;
      tasks = taskAfterDecode
          .map((element) => TaskModels.fromJson(element))
          .toList();
      toDoTasks = tasks.where((element) => element.isDone == false).toList();
      completeTask = tasks.where((element) => element.isDone == true).toList();
      highPriorityTasks = tasks
          .where((element) => element.isHighPriority)
          .toList();
      calculatePercentTasks();
    }
    isLoading = false;
    notifyListeners();
  }

  deleteTask(int? id) {
    if (id == null) return;
    tasks.removeWhere((e) => e.id == id);
    toDoTasks.removeWhere((task) => task.id == id);
    completeTask.removeWhere((task) => task.id == id);
    final updateTask = tasks.map((e) => e.toJson()).toList();
    PreferencesManager().setString(KeyStorage.tasks, jsonEncode(updateTask));
    notifyListeners();
  }

  calculatePercentTasks() {
    tootleTask = tasks.length;
    tootleDoneTask = tasks.where((e) => e.isDone).length;
    percent = tootleTask == 0 ? 0 : tootleDoneTask / tootleTask;
  }
}
