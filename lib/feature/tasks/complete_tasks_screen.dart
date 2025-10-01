import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/core/components/tasks_list_widget.dart';
import 'package:tasky/feature/tasks/tasks_controller.dart';

class CompleteTasksScreen extends StatelessWidget {
  const CompleteTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TasksController()..init(),
      builder: (context, child) {
        final controller = context.read<TasksController>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'Completed Tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: controller.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                      )
                    : Consumer<TasksController>(
                        builder: (BuildContext context, value, Widget? child) {
                          return TasksListWidget(
                            tasks: value.completeTask,
                            onTap: (value, index) async {
                              controller.doneCompleteTaskTask(value, index);
                            },
                            textMessage: 'No Task Found',
                            onDelete: (int? id) {
                              controller.deleteTask(id);
                            },
                            onEdit: () => controller.init(),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
