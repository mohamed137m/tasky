import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';
import 'package:tasky/feature/home/home_controller.dart';

class EisenhowerMatrixScreen extends StatelessWidget {
  const EisenhowerMatrixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController()..init(),
      child: const _EisenhowerMatrixContent(),
    );
  }
}

class _EisenhowerMatrixContent extends StatefulWidget {
  const _EisenhowerMatrixContent();

  @override
  State<_EisenhowerMatrixContent> createState() =>
      _EisenhowerMatrixContentState();
}

class _EisenhowerMatrixContentState extends State<_EisenhowerMatrixContent> {
  bool _hideCompleted = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eisenhower Matrix'),
        actions: [
          IconButton(
            tooltip: 'About Eisenhower Matrix',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showExplanationDialog(context),
          ),
          IconButton(
            tooltip: _hideCompleted ? 'Show Completed' : 'Hide Completed',
            icon: Icon(
              _hideCompleted
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() => _hideCompleted = !_hideCompleted);
            },
          ),
        ],
      ),
      body: Consumer<HomeController>(
        builder: (context, controller, child) {
          final allTasks = controller.allTasks;
          final tasks = _hideCompleted
              ? allTasks.where((t) => !t.isDone).toList()
              : allTasks;

          // Categorize into the 4 Quadrants
          final q1DoFirst = <TaskModels>[];
          final q2Schedule = <TaskModels>[];
          final q3Delegate = <TaskModels>[];
          final q4Eliminate = <TaskModels>[];

          for (final t in tasks) {
            final isHighPriority = t.highPriority;
            final isUrgent = _isTaskUrgent(t);

            if (isHighPriority && isUrgent) {
              q1DoFirst.add(t);
            } else if (isHighPriority && !isUrgent) {
              q2Schedule.add(t);
            } else if (!isHighPriority && isUrgent) {
              q3Delegate.add(t);
            } else {
              q4Eliminate.add(t);
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: [
                // Top matrix description banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.dashboard_customize_outlined,
                        size: 20,
                        color: Color(0xFF15B86C),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Prioritize what matters: Urgent vs Important',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${tasks.length} Tasks',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15B86C),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2x2 Interactive Quadrants Grid
                Expanded(
                  child: Row(
                    children: [
                      // Left Column: Urgent
                      Expanded(
                        child: Column(
                          children: [
                            // Q1: Do First (Urgent & Important)
                            Expanded(
                              child: _buildQuadrantCard(
                                context,
                                controller: controller,
                                title: 'Q1: DO FIRST',
                                subtitle: 'Urgent & Important',
                                badgeColor: const Color(0xFFEF4444),
                                tasks: q1DoFirst,
                                emptyText: 'No urgent critical tasks',
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Q3: Delegate (Urgent & Not Important)
                            Expanded(
                              child: _buildQuadrantCard(
                                context,
                                controller: controller,
                                title: 'Q3: DELEGATE',
                                subtitle: 'Urgent, Less Important',
                                badgeColor: const Color(0xFFF59E0B),
                                tasks: q3Delegate,
                                emptyText: 'No urgent minor tasks',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Right Column: Not Urgent
                      Expanded(
                        child: Column(
                          children: [
                            // Q2: Schedule (Not Urgent & Important)
                            Expanded(
                              child: _buildQuadrantCard(
                                context,
                                controller: controller,
                                title: 'Q2: SCHEDULE',
                                subtitle: 'Important, Not Urgent',
                                badgeColor: const Color(0xFF3B82F6),
                                tasks: q2Schedule,
                                emptyText: 'No scheduled goals',
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Q4: Eliminate (Not Urgent & Not Important)
                            Expanded(
                              child: _buildQuadrantCard(
                                context,
                                controller: controller,
                                title: 'Q4: ELIMINATE',
                                subtitle: 'Neither Urgent / Important',
                                badgeColor: const Color(0xFF10B981),
                                tasks: q4Eliminate,
                                emptyText: 'No low priority backlog',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // AdMob Banner Ad
                const Center(
                  child: TaskyBannerAdWidget(
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isTaskUrgent(TaskModels t) {
    if (t.dueDate == null) return false;
    final now = DateTime.now();
    final difference = t.dueDate!.difference(now).inHours;
    return difference <= 48; // Due within 48 hours is considered urgent
  }

  Widget _buildQuadrantCard(
    BuildContext context, {
    required HomeController controller,
    required String title,
    required String subtitle,
    required Color badgeColor,
    required List<TaskModels> tasks,
    required String emptyText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quadrant Header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.titleSmall?.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),

          // Quadrant Task List
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      emptyText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 11,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isDone = task.isDone;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xff2A2A2A)
                              : const Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xff383838)
                                : const Color(0xffE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                controller.doneTaskById(!isDone, task.id);
                              },
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? const Color(0xFF15B86C)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: isDone
                                        ? const Color(0xFF15B86C)
                                        : (isDark
                                            ? Colors.white38
                                            : Colors.black38),
                                    width: 1.5,
                                  ),
                                ),
                                child: isDone
                                    ? const Icon(
                                        Icons.check,
                                        size: 13,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.taskTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isDone
                                      ? (isDark ? Colors.white38 : Colors.black38)
                                      : theme.textTheme.titleMedium?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.dashboard_customize_rounded, color: Color(0xFF15B86C)),
              SizedBox(width: 10),
              Text('The Eisenhower Matrix'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Organize your workload using the 4 quadrants of productivity:\n',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('• Q1 (Do First): High priority tasks with impending deadlines. Take action immediately.'),
              SizedBox(height: 6),
              Text('• Q2 (Schedule): Important long-term goals and strategic work. Protect time for these.'),
              SizedBox(height: 6),
              Text('• Q3 (Delegate): Urgent requests with lower overall impact.'),
              SizedBox(height: 6),
              Text('• Q4 (Eliminate): Low value items that drain your focus and energy.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
