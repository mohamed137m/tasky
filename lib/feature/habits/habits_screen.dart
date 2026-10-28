import 'package:flutter/material.dart';
import 'package:tasky/core/models/habit_item.dart';
import 'package:tasky/core/services/habits_service.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final HabitsService _service = HabitsService();

  @override
  void initState() {
    super.initState();
    _service.init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits & Consistency'),
        actions: [
          IconButton(
            tooltip: 'Add New Habit',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddHabitDialog(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<HabitItem>>(
        valueListenable: _service.habitsNotifier,
        builder: (context, habits, _) {
          final completedToday = _service.totalCompletedToday;
          final totalHabits = habits.length;
          final completionRatio =
              totalHabits > 0 ? completedToday / totalHabits : 0.0;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              // Today's Progress Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xff1C2822), const Color(0xff181818)]
                        : [const Color(0xffECFDF5), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF15B86C).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DAILY HABIT GOALS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: Color(0xFF15B86C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedToday of $totalHabits Completed',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15B86C).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(completionRatio * 100).toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF15B86C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completionRatio,
                        minHeight: 7,
                        backgroundColor: isDark
                            ? Colors.white10
                            : const Color(0xffE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF15B86C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // GitHub Activity Heatmap Grid
              _buildHeatmapCard(context, isDark),

              const SizedBox(height: 24),

              // Habits Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Habits",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddHabitDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Habit', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Habits List
              if (habits.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      'No habits yet. Tap + to build your first positive habit!',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                )
              else
                ...habits.map((habit) => _buildHabitCard(context, habit, isDark)),

              const SizedBox(height: 20),

              // AdMob Banner Ad
              const Center(
                child: TaskyBannerAdWidget(
                  margin: EdgeInsets.symmetric(vertical: 4),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeatmapCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final heatmapData = _service.getHeatmapData(28); // 4 weeks = 28 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🟩', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    'Consistency Heatmap',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                'Last 4 Weeks',
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7 rows (Days of week) x 4 columns (Weeks)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (weekIndex) {
              return Column(
                children: List.generate(7, (dayIndex) {
                  final dayOffset = (3 - weekIndex) * 7 + (6 - dayIndex);
                  final cellDate = today.subtract(Duration(days: dayOffset));
                  final ratio = heatmapData[cellDate] ?? 0.0;

                  Color cellColor;
                  if (ratio <= 0.0) {
                    cellColor = isDark
                        ? const Color(0xff2A2A2A)
                        : const Color(0xffE2E8F0);
                  } else if (ratio < 0.4) {
                    cellColor = const Color(0xFF15B86C).withValues(alpha: 0.35);
                  } else if (ratio < 0.8) {
                    cellColor = const Color(0xFF15B86C).withValues(alpha: 0.65);
                  } else {
                    cellColor = const Color(0xFF15B86C);
                  }

                  final isToday = cellDate == today;

                  return Container(
                    margin: const EdgeInsets.all(3.5),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(5),
                      border: isToday
                          ? Border.all(color: Colors.white, width: 1.5)
                          : null,
                    ),
                  );
                }),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 10),
              ),
              const SizedBox(width: 6),
              _buildLegendBox(
                isDark ? const Color(0xff2A2A2A) : const Color(0xffE2E8F0),
              ),
              _buildLegendBox(const Color(0xFF15B86C).withValues(alpha: 0.35)),
              _buildLegendBox(const Color(0xFF15B86C).withValues(alpha: 0.65)),
              _buildLegendBox(const Color(0xFF15B86C)),
              const SizedBox(width: 6),
              Text(
                'More',
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, HabitItem habit, bool isDark) {
    final theme = Theme.of(context);
    final isDone = habit.isCompletedToday;
    final streak = habit.currentStreak;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? const Color(0xFF15B86C).withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: habit.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(habit.icon, color: habit.color, size: 22),
          ),
          const SizedBox(width: 12),

          // Title & Streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone
                        ? (isDark ? Colors.white38 : Colors.black38)
                        : theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '$streak ${streak == 1 ? 'day' : 'days'} streak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: streak > 0
                            ? const Color(0xFFF59E0B)
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete icon button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: isDark ? Colors.white38 : Colors.black26,
            onPressed: () => _service.deleteHabit(habit.id),
          ),

          // Checkbox toggle
          InkWell(
            onTap: () => _service.toggleHabit(habit.id),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF15B86C) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF15B86C)
                      : (isDark ? Colors.white38 : Colors.black38),
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedIcon = 'water';
    int selectedColor = 0xFF15B86C;

    final icons = [
      {'key': 'water', 'icon': Icons.water_drop_outlined, 'name': 'Water'},
      {'key': 'book', 'icon': Icons.menu_book_outlined, 'name': 'Read'},
      {'key': 'workout', 'icon': Icons.fitness_center_outlined, 'name': 'Gym'},
      {'key': 'code', 'icon': Icons.code_rounded, 'name': 'Code'},
      {'key': 'meditate', 'icon': Icons.self_improvement_rounded, 'name': 'Zen'},
      {'key': 'journal', 'icon': Icons.edit_note_rounded, 'name': 'Journal'},
      {'key': 'walk', 'icon': Icons.directions_walk_rounded, 'name': 'Walk'},
      {'key': 'sleep', 'icon': Icons.bedtime_outlined, 'name': 'Sleep'},
    ];

    final colors = [
      0xFF15B86C, // Green
      0xFF3B82F6, // Blue
      0xFF8B5CF6, // Purple
      0xFFEC4899, // Pink
      0xFFF59E0B, // Amber
      0xFFEF4444, // Red
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Daily Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Meditate for 10 minutes',
                        labelText: 'Habit Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose Icon',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((item) {
                        final isSelected = selectedIcon == item['key'];
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = item['key'] as String;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF15B86C).withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF15B86C)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              size: 20,
                              color: isSelected
                                  ? const Color(0xFF15B86C)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose Color',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: colors.map((col) {
                        final isSelected = selectedColor == col;
                        return InkWell(
                          onTap: () {
                            setDialogState(() => selectedColor = col);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Color(col),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2.5)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = titleController.text.trim();
                    if (text.isNotEmpty) {
                      _service.addHabit(
                        title: text,
                        iconKey: selectedIcon,
                        colorValue: selectedColor,
                      );
                      Navigator.pop(dialogCtx);
                    }
                  },
                  child: const Text('Create Habit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
