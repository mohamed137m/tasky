import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';

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
    await HiveStorageManger().saveTasks(tasks);

    _loadTaskData();
    notifyListeners();
  }

  doneCompleteTaskTask(bool? value, int? index) async {
    if (index == null) return;
    completeTask[index].isDone = value ?? false;

    final newIndex = tasks.indexWhere((e) => e.id == completeTask[index].id);

    tasks[newIndex] = completeTask[index];
    await HiveStorageManger().saveTasks(tasks);

    _loadTaskData();
    notifyListeners();
  }

  doneHighPriorityTaskTask(bool? value, int? index) async {
    if (index == null) return;
    highPriorityTasks[index].isDone = value ?? false;

    final newIndex = tasks.indexWhere(
      (e) => e.id == highPriorityTasks[index].id,
    );

    tasks[newIndex] = highPriorityTasks[index];
    await HiveStorageManger().saveTasks(tasks);

    _loadTaskData();
    notifyListeners();
  }

  void _loadTaskData() {
    isLoading = true;
    tasks = HiveStorageManger().loadTasks();
    toDoTasks = tasks.where((element) => element.isDone == false).toList();
    completeTask = tasks.where((element) => element.isDone == true).toList();
    highPriorityTasks = tasks
        .where((element) => element.isHighPriority)
        .toList();
    calculatePercentTasks();
    isLoading = false;
    notifyListeners();
  }

  deleteTask(int? id) {
    if (id == null) return;
    tasks.removeWhere((e) => e.id == id);
    toDoTasks.removeWhere((task) => task.id == id);
    completeTask.removeWhere((task) => task.id == id);
    HiveStorageManger().saveTasks(tasks);
    notifyListeners();
  }

  calculatePercentTasks() {
    tootleTask = tasks.length;
    tootleDoneTask = tasks.where((e) => e.isDone).length;
    percent = tootleTask == 0 ? 0 : tootleDoneTask / tootleTask;
  }
}
