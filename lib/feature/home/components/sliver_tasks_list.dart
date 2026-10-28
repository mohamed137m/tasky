import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/core/components/task_list_item.dart';
import 'package:tasky/feature/home/home_controller.dart';

class SliverTasksList extends StatelessWidget {
  const SliverTasksList({super.key, this.textMessage});
  final String? textMessage;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (BuildContext context, HomeController controller, Widget? child) {
        if (controller.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF15B86C),
              ),
            ),
          );
        }

        final tasks = controller.filteredTasks;
        if (tasks.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  textAlign: TextAlign.center,
                  controller.tasks.isEmpty
                      ? (textMessage ?? 'No tasks yet... Click + to add one! ✍️')
                      : 'No tasks in "${controller.selectedCategory}" category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 80),
          sliver: SliverList.separated(
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 10);
            },
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              return TaskListItem(
                models: tasks[index],
                onChanged: (bool? value) {
                  controller.doneTask(value, index);
                },
                onDelete: (int id) {
                  controller.deleteTask(id);
                },
                onEdit: () => controller.loadTaskData(),
              );
            },
          ),
        );
      },
    );
  }
}
