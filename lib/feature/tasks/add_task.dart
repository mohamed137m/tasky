import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/widgets/custom_text_form_field.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  bool isHighPriority = true;
  final TextEditingController taskNameController = TextEditingController();

  final TextEditingController taskDescriptionController =
      TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text('New Task'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          controllers: taskNameController,
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please Enter Task Name';
                            }
                            return null;
                          },
                          hintText: 'Finish UI design for login screen',
                          textTitle: 'Task Name',
                        ),
                        SizedBox(height: 28),
                        CustomTextFormField(
                          maxLines: 6,
                          controllers: taskDescriptionController,
                          hintText:
                              'Finish onboarding UI and hand off to devs by Thursday.',
                          textTitle: 'Task Description',
                        ),

                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'High Priority',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Switch(
                              value: isHighPriority,
                              onChanged: (bool value) {
                                setState(() {
                                  isHighPriority = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_key.currentState?.validate() ?? false) {
                      final taskJson = PreferencesManager().getString('tasks');
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
                      await PreferencesManager().setString('tasks', taskEncode);
                      Navigator.of(context).pop(true);
                    }
                  },
                  label: Text('Add Task'),
                  icon: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(MediaQuery.of(context).size.width, 42),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
