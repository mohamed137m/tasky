import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/feature/tasks/add_task.dart';
import 'package:tasky/feature/home/components/achieved_tasks_widget.dart';
import 'package:tasky/feature/home/components/high_priority_tasks_widget.dart';
import 'package:tasky/feature/home/components/sliver_tasks_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  String? motivationQuoteKey;
  String? userImagePath;
  bool isLoading = false;
  List<TaskModels> tasks = [];
  int tootleTask = 0;
  int tootleDoneTask = 0;
  double percent = 0;
  @override
  void initState() {
    _loadUserName();
    _loadTaskData();
    _loadMotivationQuote();
    super.initState();
  }

  void _loadUserName() async {
    setState(() {
      username = PreferencesManager().getString('Username');
      userImagePath = PreferencesManager().getString('user_image');
    });
  }

  void _loadTaskData() async {
    setState(() {
      isLoading = true;
    });
    final finalTask = PreferencesManager().getString('tasks');
    if (finalTask != null) {
      final taskAfterDecode = jsonDecode(finalTask) as List<dynamic>;
      setState(() {
        tasks = taskAfterDecode
            .map((element) => TaskModels.fromJson(element))
            .toList();
        _calculatePercentTasks();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _loadMotivationQuote() async {
    setState(() {
      motivationQuoteKey =
          PreferencesManager().getString('description') ??
          'One task at a time.One step closer.';
    });
  }

  _calculatePercentTasks() {
    tootleTask = tasks.length;
    tootleDoneTask = tasks.where((e) => e.isDone).length;
    percent = tootleTask == 0 ? 0 : tootleDoneTask / tootleTask;
  }

  _deleteTask(int? id) {
    if (id == null) return;
    setState(() {
      tasks.removeWhere((task) => task.id == id);
      _calculatePercentTasks();
    });
    final updateTask = tasks.map((e) => e.toJson()).toList();
    PreferencesManager().setString('tasks', jsonEncode(updateTask));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 44,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final bool? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return AddTask();
                },
              ),
            );
            if (result != null && result) {
              _loadTaskData();
            }
          },
          label: Text('Add New Task'),
          icon: Icon(Icons.add),
          backgroundColor: Color(0xff15B86C),
          foregroundColor: Color(0xffFFFCFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(100),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundColor: Colors.transparent,
                        backgroundImage: userImagePath == null
                            ? AssetImage('assets/image/Thumbnail.png')
                            : FileImage(File(userImagePath!)),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Evening $username ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            motivationQuoteKey ??
                                'One task at a time.One step closer.',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Yuhuu ,Your work Is',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Row(
                    children: [
                      Text(
                        'almost done ! ',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      SvgPicture.asset(
                        'assets/image/waving_hand.svg',
                        width: 32,
                        height: 32,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  AchievedTasksWidget(
                    tootleDoneTask: tootleDoneTask,
                    tootleTask: tootleTask,
                    percent: percent,
                  ),
                  SizedBox(height: 16),
                  HighPriorityTasksWidget(
                    tasks: tasks,
                    onTap: (bool? value, int? index) async {
                      setState(() {
                        tasks[index!].isDone = value ?? false;
                        _calculatePercentTasks();
                      });
                      final updatedTask = tasks
                          .map((element) => element.toJson())
                          .toList();
                      PreferencesManager().setString(
                        'tasks',
                        jsonEncode(updatedTask),
                      );
                    },
                    refresh: () {
                      _loadTaskData();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 16),
                    child: Text(
                      "My Tasks",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  )
                : SliverTasksList(
                    tasks: tasks,
                    onTap: (bool? value, int? index) async {
                      setState(() {
                        tasks[index!].isDone = value ?? false;
                        _calculatePercentTasks();
                      });
                      final updatedTask = tasks
                          .map((element) => element.toJson())
                          .toList();
                      PreferencesManager().setString(
                        'tasks',
                        jsonEncode(updatedTask),
                      );
                    },
                    textMessage:
                        'There are no tasks yet... Click + to add the first task ✍️',
                    onDelete: (int? id) {
                      _deleteTask(id);
                    },
                    onEdit: () => _loadTaskData(),
                  ),
          ],
        ),
      ),
    );
  }
}
