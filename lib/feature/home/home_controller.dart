import 'package:flutter/cupertino.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/preferences_manager.dart';

class HomeController extends ChangeNotifier {
  String? username;
  String? motivationQuoteKey;
  String? userImagePath;
  bool isLoading = false;
  List<TaskModels> tasks = [];
  int tootleTask = 0;
  int tootleDoneTask = 0;
  double percent = 0;

  HomeController() {
    init();
  }

  void init() {
    loadUserData();
    loadTaskData();
    loadMotivationQuote();
  }

  doneTask(bool? value, int? index) async {
    tasks[index!].isDone = value ?? false;
    calculatePercentTasks();
    await HiveStorageManger().saveTasks(tasks);
    notifyListeners();
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
        'One task at a time.One step closer.';
    notifyListeners();
  }

  calculatePercentTasks() {
    tootleTask = tasks.length;
    tootleDoneTask = tasks.where((e) => e.isDone).length;
    percent = tootleTask == 0 ? 0 : tootleDoneTask / tootleTask;
    notifyListeners();
  }

  deleteTask(int? id) {
    if (id == null) return;
    tasks.removeWhere((task) => task.id == id);
    calculatePercentTasks();
    HiveStorageManger().saveTasks(tasks);
    notifyListeners();
  }
}
