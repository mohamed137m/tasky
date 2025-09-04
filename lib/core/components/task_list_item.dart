import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/enum/enum_menu_actions_item.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/core/widgets/custom_check_box_widget.dart';
import 'package:tasky/core/widgets/custom_text_form_field.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    super.key,
    required this.models,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });
  _showAlertDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Do you want to delete the task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onDelete(models.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  final TaskModels models;
  final Function(bool? value) onChanged;
  final Function(int id) onDelete;
  final Function onEdit;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeController.isDark()
              ? Colors.transparent
              : Color(0xffD1DAD6),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 8),
          CustomCheckBoxWidget(
            value: models.isDone,
            onChanged: (value) {
              onChanged(value);
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  maxLines: 1,
                  models.taskName,

                  style: models.isDone
                      ? Theme.of(context).textTheme.displayMedium
                      : Theme.of(context).textTheme.titleMedium,
                ),
                if (models.taskDescription.isNotEmpty)
                  Text(
                    maxLines: 1,
                    models.taskDescription,
                    style: models.isDone
                        ? Theme.of(context).textTheme.displayMedium
                        : Theme.of(context).textTheme.labelMedium,
                  ),
              ],
            ),
          ),
          PopupMenuButton<EnumMenuActionsItem>(
            icon: Icon(
              Icons.more_vert,
              color: ThemeController.isDark()
                  ? models.isDone
                        ? Color(0xffA0A0A0)
                        : Color(0xffFFFCFC)
                  : models.isDone
                  ? Color(0xff6A6A6A)
                  : Colors.black,
            ),
            onSelected: (value) async {
              switch (value) {
                case EnumMenuActionsItem.markAsDone:
                  onChanged(!models.isDone);
                  break;
                case EnumMenuActionsItem.delete:
                  await _showAlertDialog(context);

                case EnumMenuActionsItem.edit:
                  final result = await _showBottomSheet(context, models);
                  if (result == true) {
                    onEdit();
                  }
              }
            },
            itemBuilder: (context) => EnumMenuActionsItem.values
                .map(
                  (e) => PopupMenuItem<EnumMenuActionsItem>(
                    value: e,
                    child: Text(
                      e == EnumMenuActionsItem.markAsDone
                          ? (models.isDone ? "Un Done" : "Mark As Done")
                          : e.name,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showBottomSheet(context, TaskModels model) async {
    final TextEditingController taskNameController = TextEditingController(
      text: models.taskName,
    );
    final TextEditingController taskDescriptionController =
        TextEditingController(text: models.taskDescription);
    final GlobalKey<FormState> key = GlobalKey<FormState>();
    bool isHighPriority = model.isHighPriority;
    return showModalBottomSheet<bool>(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Form(
                key: key,
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
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
                        if (key.currentState?.validate() ?? false) {
                          final taskJson = PreferencesManager().getString(
                            'tasks',
                          );
                          List<dynamic> listTasks = [];

                          if (taskJson != null) {
                            listTasks = jsonDecode(taskJson);
                          }
                          TaskModels newModels = TaskModels(
                            id: model.id,
                            taskName: taskNameController.text,
                            taskDescription: taskDescriptionController.text,
                            isHighPriority: isHighPriority,
                            isDone: model.isDone,
                          );

                          final item = listTasks.firstWhere(
                            (e) => e['id'] == model.id,
                          );

                          final int index = listTasks.indexOf(item);

                          listTasks[index] = newModels;

                          final taskEncode = jsonEncode(listTasks);
                          await PreferencesManager().setString(
                            'tasks',
                            taskEncode,
                          );
                          Navigator.of(context).pop(true);
                        }
                      },
                      label: Text('Edit'),
                      icon: Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(MediaQuery.of(context).size.width, 42),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
