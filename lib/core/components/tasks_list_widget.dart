import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/components/task_list_item.dart';

class TasksListWidget extends StatelessWidget {
  const TasksListWidget({
    super.key,
    required this.tasks,
    required this.onTap,
    this.textMessage,
    required this.onDelete, required this.onEdit,
  });
  final List<TaskModels> tasks;
  final Function(bool?, int?) onTap;
  final Function(int?) onDelete;
  final Function onEdit;
  final String? textMessage;
  @override
  Widget build(BuildContext context) {
    return tasks.isEmpty
        ? Center(
            child: Text(
              textAlign: TextAlign.center,
              textMessage ?? 'No Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          )
        : ListView.separated(
            padding: EdgeInsetsDirectional.only(bottom: 60),
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 8);
            },
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              return TaskListItem(
                models: tasks[index],
                onChanged: (value) => onTap(value, index),
                onDelete: (id) {
                  onDelete(id);
                }, onEdit: ()=> onEdit(),
              );
            },
          );
  }
}
