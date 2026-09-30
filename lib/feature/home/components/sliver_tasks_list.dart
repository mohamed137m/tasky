import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/core/components/task_list_item.dart';
import 'package:tasky/feature/home/home_controller.dart';

class SliverTasksList extends StatelessWidget {
  const SliverTasksList({super.key, this.textMessage});
  final String? textMessage;
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, HomeController controller, Widget? child) {
            return controller.isLoading
                ? SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  )
                : controller.tasks.isEmpty
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
                      itemCount: controller.tasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TaskListItem(
                          models: controller.tasks[index],
                          onChanged: (bool? value) {
                            controller.calculatePercentTasks();
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
