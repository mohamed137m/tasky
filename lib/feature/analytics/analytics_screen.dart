import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/task_categories.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/streak_service.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<TaskModels> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final tasks = HiveStorageManger().loadTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  // Calculate completed tasks per day over the last 7 days
  List<double> _getLast7DaysCompletions() {
    final now = DateTime.now();
    final counts = List<double>.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final nextDay = day.add(const Duration(days: 1));

      final completedOnDay = _tasks.where((t) {
        if (!t.isDone) return false;
        final compDate = t.completedAt ?? t.dueDate ?? DateTime.now();
        return compDate.isAfter(day.subtract(const Duration(seconds: 1))) &&
            compDate.isBefore(nextDay);
      }).length;

      counts[i] = completedOnDay.toDouble();
    }
    return counts;
  }

  String _getDayLabel(int index) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - index));
    return DateFormat('E').format(day); // e.g. Mon, Tue
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((t) => t.isDone).length;
    final pendingTasks = totalTasks - completedTasks;
    final completionRate =
        totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).toInt();

    final streak = StreakService().currentStreak;
    final bestStreak = StreakService().bestStreak;
    final totalXp = StreakService().totalXP;
    final level = StreakService().currentLevel;
    final levelTitle = StreakService().levelTitle;
    final xpInCurrentLevel = totalXp % 50;
    final xpProgress = xpInCurrentLevel / 50.0;

    final weeklyData = _getLast7DaysCompletions();
    final maxCompletions = weeklyData.reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxCompletions < 4 ? 4 : maxCompletions + 1).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Productivity Analytics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gamification Level & XP Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0F3E2E), const Color(0xFF1B2824)]
                            : [const Color(0xFF15B86C), const Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF15B86C).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                                Text(
                                  'Level $level',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  levelTitle,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$streak Days Streak',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$totalXp Total XP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$xpInCurrentLevel / 50 XP to Level ${level + 1}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: xpProgress,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4 Summary Metrics (Grid 2x2)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          context: context,
                          title: 'Completed',
                          value: '$completedTasks',
                          subtitle: 'out of $totalTasks tasks',
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF15B86C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          context: context,
                          title: 'Pending',
                          value: '$pendingTasks',
                          subtitle: 'active tasks',
                          icon: Icons.pending_actions_rounded,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          context: context,
                          title: 'Completion Rate',
                          value: '$completionRate%',
                          subtitle: 'task success rate',
                          icon: Icons.pie_chart_rounded,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          context: context,
                          title: 'Best Streak',
                          value: '$bestStreak Days',
                          subtitle: 'personal record 🏆',
                          icon: Icons.emoji_events_rounded,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Weekly Activity Chart Card
                  Text(
                    'Weekly Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasks Finished Past 7 Days',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              maxY: chartMaxY,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${rod.toY.toInt()} tasks',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= 7) {
                                        return const SizedBox();
                                      }
                                      final isToday = idx == 6;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          isToday ? 'Today' : _getDayLabel(idx),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isToday
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isToday
                                                ? const Color(0xFF15B86C)
                                                : (isDark
                                                    ? Colors.white60
                                                    : Colors.black54),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(7, (i) {
                                final isToday = i == 6;
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: weeklyData[i],
                                      color: isToday
                                          ? const Color(0xFF15B86C)
                                          : (weeklyData[i] > 0
                                              ? const Color(0xFF3B82F6)
                                              : (isDark
                                                  ? Colors.white12
                                                  : Colors.black12)),
                                      width: 18,
                                      borderRadius: BorderRadius.circular(6),
                                      backDrawRodData: BackgroundBarChartRodData(
                                        show: true,
                                        toY: chartMaxY,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.03)
                                            : Colors.black.withValues(alpha: 0.03),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tasks By Category Breakdown
                  Text(
                    'Tasks by Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...TaskCategory.all.map((cat) {
                    final catTasks = _tasks
                        .where((t) =>
                            t.category.toLowerCase() == cat.id.toLowerCase())
                        .toList();
                    final catTotal = catTasks.length;
                    final catDone = catTasks.where((t) => t.isDone).length;
                    final catProgress =
                        catTotal == 0 ? 0.0 : catDone / catTotal;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cat.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: cat.color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cat.nameEn,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '$catDone / $catTotal Done',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xffB0B0B0)
                                      : const Color(0xff5A6862),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: catProgress,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : Colors.black.withValues(alpha: 0.06),
                              valueColor: AlwaysStoppedAnimation(cat.color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // AdMob Banner Ad
                  const Center(
                    child: TaskyBannerAdWidget(
                      margin: EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: isDark ? const Color(0xffA8A8A8) : const Color(0xff5A6862),
                ),
          ),
        ],
      ),
    );
  }
}
