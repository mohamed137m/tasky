import 'package:flutter/material.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/widgets/task_list_item.dart';

class SliverTasksList extends StatelessWidget {
  const SliverTasksList({
    super.key,
    required this.tasks,
    required this.onTap,
    this.textMessage, required this.onDelete, required this.onEdit,
  });
  final List<TaskModels> tasks;
  final Function(bool?, int?) onTap;
  final Function(int?) onDelete;
  final Function onEdit;
  final String? textMessage;
  @override
  Widget build(BuildContext context) {
    return tasks.isEmpty
        ? SliverToBoxAdapter(
            child: Center(
              child: Text(
                textAlign: TextAlign.center,
                textMessage ?? 'No Data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          )
        : SliverPadding(
            padding: EdgeInsetsGeometry.only(bottom: 60),
            sliver: SliverList.separated(
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 8);
              },
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                return TaskListItem(
                  models: tasks[index],
                  onChanged: (bool? value) {
                    onTap(value, index);
                  },
                  onDelete: (int id) {
                    onDelete(id);
                  }, onEdit: ()=> onEdit(),
                );
              },
            ),
          );
  }
}
