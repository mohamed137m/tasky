import 'package:flutter/cupertino.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/firestore_sync_service.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/services/streak_service.dart';

class HomeController extends ChangeNotifier {
  String? username;
  String? motivationQuoteKey;
  String? userImagePath;
  bool isLoading = false;
  List<TaskModels> tasks = [];
  String selectedCategory = 'All';
  int tootleTask = 0;
  int tootleDoneTask = 0;
  double percent = 0;

  HomeController() {
    init();
  }

  void init() {
    StreakService().init();
    loadUserData();
    loadTaskData();
    loadMotivationQuote();
  }

  List<TaskModels> get filteredTasks {
    if (selectedCategory == 'All') {
      return tasks;
    }
    return tasks
        .where((t) => t.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  int countForCategory(String category) {
    if (category == 'All') return tasks.length;
    return tasks
        .where((t) => t.category.toLowerCase() == category.toLowerCase())
        .length;
  }

  List<TaskModels> get allTasks => tasks;

  Future<void> doneTask(bool? value, int? index) async {
    if (index == null || index < 0 || index >= filteredTasks.length) return;
    final task = filteredTasks[index];
    final realIndex = tasks.indexWhere((t) => t.id == task.id);
    if (realIndex != -1) {
      tasks[realIndex].isDone = value ?? false;
      if (value == true) {
        tasks[realIndex].completedAt = DateTime.now();
        NotificationService().cancelTaskReminder(task.id);
      } else {
        NotificationService().scheduleTaskReminder(tasks[realIndex]);
      }
      calculatePercentTasks();
      await HiveStorageManger().saveTasks(tasks);
      FirestoreSyncService().syncToCloud();
      notifyListeners();
    }
  }

  Future<void> doneTaskById(bool? value, int? taskId) async {
    if (taskId == null) return;
    final realIndex = tasks.indexWhere((t) => t.id == taskId);
    if (realIndex != -1) {
      tasks[realIndex].isDone = value ?? false;
      if (value == true) {
        tasks[realIndex].completedAt = DateTime.now();
        NotificationService().cancelTaskReminder(taskId);
      } else {
        NotificationService().scheduleTaskReminder(tasks[realIndex]);
      }
      calculatePercentTasks();
      await HiveStorageManger().saveTasks(tasks);
      FirestoreSyncService().syncToCloud();
      notifyListeners();
    }
  }

  void loadUserData() async {
    username = PreferencesManager().getString(KeyStorage.username);
    userImagePath = PreferencesManager().getString(KeyStorage.userImage);
    notifyListeners();
  }

  void loadTaskData() async {
    isLoading = true;
    tasks = HiveStorageManger().loadTasks();
    calculatePercentTasks();
    isLoading = false;
    notifyListeners();
  }

  void loadMotivationQuote() async {
    motivationQuoteKey =
        PreferencesManager().getString(KeyStorage.description) ??
        'One task at a time. One step closer.';
    notifyListeners();
  }

  void calculatePercentTasks() {
    tootleTask = tasks.length;
    tootleDoneTask = tasks.where((e) => e.isDone).length;
    percent = tootleTask == 0 ? 0 : tootleDoneTask / tootleTask;
    notifyListeners();
  }

  void deleteTask(int? id) {
    if (id == null) return;
    NotificationService().cancelTaskReminder(id);
    tasks.removeWhere((task) => task.id == id);
    calculatePercentTasks();
    HiveStorageManger().saveTasks(tasks);
    FirestoreSyncService().deleteTaskFromCloud(id);
    FirestoreSyncService().syncToCloud();
    notifyListeners();
  }
}
