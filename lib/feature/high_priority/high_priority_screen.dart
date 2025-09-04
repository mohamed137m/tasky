import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/components/tasks_list_widget.dart';

class HighPriorityScreen extends StatefulWidget {
  const HighPriorityScreen({super.key});

  @override
  State<HighPriorityScreen> createState() => _HighPriorityScreenState();
}

class _HighPriorityScreenState extends State<HighPriorityScreen> {
  bool isLoading = false;
  List<TaskModels> highPriorityTasks = [];
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
        highPriorityTasks = taskAfterDecode
            .map((element) => TaskModels.fromJson(element))
            .where((element) => element.isHighPriority)
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
        highPriorityTasks.removeWhere((task) => task.id == id);
      });
      final updateTask = tasksModel.map((e) => e.toJson()).toList();
      PreferencesManager().setString('tasks', jsonEncode(updateTask));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text('High Priority Tasks'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              )
            : TasksListWidget(
                tasks: highPriorityTasks,
                onTap: (value, index) async {
                  setState(() {
                    highPriorityTasks[index!].isDone = value ?? false;
                  });
                  final allData = PreferencesManager().getString('tasks');
                  if (allData != null) {
                    List<TaskModels> allDataList = (jsonDecode(allData) as List)
                        .map((element) => TaskModels.fromJson(element))
                        .toList();
                    final newIndex = allDataList.indexWhere(
                      (e) => e.id == highPriorityTasks[index!].id,
                    );

                    allDataList[newIndex] = highPriorityTasks[index!];
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
                }, onEdit: ()=>_loadTaskData(),
              ),
      ),
    );
  }
}
