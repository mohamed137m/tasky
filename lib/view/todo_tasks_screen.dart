import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/widgets/tasks_list_widget.dart';

class TodoTasksScreen extends StatefulWidget {
  const TodoTasksScreen({super.key});

  @override
  State<TodoTasksScreen> createState() => _TodoTasksScreenState();
}

class _TodoTasksScreenState extends State<TodoTasksScreen> {
  bool isLoading = false;
  List<TaskModels> toDoTasks = [];

  @override
  void initState() {
    _loadTaskData();
    super.initState();
  }

  void _loadTaskData() async {
    setState(() {
      isLoading = true;
    });
    final finalTask = PreferencesManager().getString('tasks');
    if (finalTask != null) {
      final taskAfterDecode = jsonDecode(finalTask) as List<dynamic>;
      setState(() {
        toDoTasks = taskAfterDecode
            .map((element) => TaskModels.fromJson(element))
            .where((element) => element.isDone == false)
            .toList();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  _deleteTask(int? id) {
    List<TaskModels> tasksModel = [];
    if (id == null) return;
    final finalTask = PreferencesManager().getString('tasks');
    if (finalTask != null) {
      final taskAfterDecode = jsonDecode(finalTask) as List<dynamic>;
      tasksModel = taskAfterDecode.map((e) => TaskModels.fromJson(e)).toList();
      tasksModel.removeWhere((e) => e.id == id);

      setState(() {
        toDoTasks.removeWhere((task) => task.id == id);
      });
      final updateTask = tasksModel.map((e) => e.toJson()).toList();
      PreferencesManager().setString('tasks', jsonEncode(updateTask));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'To Do Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  )
                : TasksListWidget(
                    tasks: toDoTasks,
                    onTap: (value, index) async {
                      setState(() {
                        toDoTasks[index!].isDone = value ?? false;
                      });
                      final allData = PreferencesManager().getString('tasks');
                      if (allData != null) {
                        List<TaskModels> allDataList =
                            (jsonDecode(allData) as List)
                                .map((element) => TaskModels.fromJson(element))
                                .toList();
                        final newIndex = allDataList.indexWhere(
                          (e) => e.id == toDoTasks[index!].id,
                        );

                        allDataList[newIndex] = toDoTasks[index!];
                        PreferencesManager().setString(
                          'tasks',
                          jsonEncode(allDataList),
                        );

                        _loadTaskData();
                      }
                    },
                    textMessage: 'No Task Found',
                    onDelete: (int? id) {
                      _deleteTask(id);
                    },
                    onEdit: () => _loadTaskData(),
                  ),
          ),
        ),
      ],
    );
  }
}
