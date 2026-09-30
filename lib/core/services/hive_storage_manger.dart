import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/constants.dart';

class HiveStorageManger {
  static final HiveStorageManger _instance = HiveStorageManger._();
  HiveStorageManger._();

  factory HiveStorageManger() {
    return _instance;
  }

  late Box<TaskModels> _tasksBox;

  init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskModelsAdapter());
    await Hive.openBox<TaskModels>(Constants.tasksBoxName);
    _tasksBox = Hive.box<TaskModels>(Constants.tasksBoxName);
  }

  saveTasks( List<TaskModels> tasks) async {
    await _tasksBox.clear();
    await _tasksBox.addAll(tasks);
    
  }

  List<TaskModels> loadTasks() {
    return _tasksBox.values.toList();
  }

clear()async {
    await _tasksBox.clear();}
}
