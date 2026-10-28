import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/core/components/tasks_list_widget.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';
import 'package:tasky/feature/eisenhower/eisenhower_matrix_screen.dart';
import 'package:tasky/feature/habits/habits_screen.dart';
import 'package:tasky/feature/tasks/tasks_controller.dart';

class TasksTabScreen extends StatelessWidget {
  const TasksTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TasksController()..init(),
      child: const _TasksTabContent(),
    );
  }
}

class _TasksTabContent extends StatelessWidget {
  const _TasksTabContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            IconButton(
              tooltip: 'Eisenhower Matrix',
              icon: const Icon(Icons.dashboard_customize_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EisenhowerMatrixScreen(),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Habits & Heatmap',
              icon: const Icon(Icons.calendar_view_week_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HabitsScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Consumer<TasksController>(
              builder: (context, controller, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark
                        ? const Color(0xffB0B0B0)
                        : const Color(0xff5A6862),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(
                        text: 'To Do (${controller.toDoTasks.length})',
                      ),
                      Tab(
                        text: 'Completed (${controller.completeTask.length})',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        body: Consumer<TasksController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF15B86C)),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      // To Do tab
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: TasksListWidget(
                          tasks: controller.toDoTasks,
                          onTap: (value, index) {
                            controller.doneTask(value, index);
                          },
                          textMessage: 'All caught up! No pending tasks 🎉',
                          onDelete: (int? id) => controller.deleteTask(id),
                          onEdit: () => controller.init(),
                        ),
                      ),
                      // Completed tab
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: TasksListWidget(
                          tasks: controller.completeTask,
                          onTap: (value, index) {
                            controller.doneCompleteTaskTask(value, index);
                          },
                          textMessage: 'No completed tasks yet. Finish a task to see it here! 💪',
                          onDelete: (int? id) => controller.deleteTask(id),
                          onEdit: () => controller.init(),
                        ),
                      ),
                    ],
                  ),
                ),
                const TaskyBannerAdWidget(
                  margin: EdgeInsets.symmetric(vertical: 4),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
