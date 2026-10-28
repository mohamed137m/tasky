import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tasky/add_tasks/add_task.dart';
import 'package:tasky/core/constants/task_categories.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/core/services/streak_service.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';
import 'package:tasky/feature/ai_planner/ai_daily_planner_sheet.dart';
import 'package:tasky/feature/eisenhower/eisenhower_matrix_screen.dart';
import 'package:tasky/feature/garden/focus_garden_screen.dart';
import 'package:tasky/feature/habits/habits_screen.dart';
import 'package:tasky/feature/home/components/achieved_tasks_widget.dart';
import 'package:tasky/feature/home/components/activity_rings_card.dart';
import 'package:tasky/feature/home/components/high_priority_tasks_widget.dart';
import 'package:tasky/feature/home/components/share_streak_modal.dart';
import 'package:tasky/feature/home/components/sliver_tasks_list.dart';
import 'package:tasky/feature/home/home_controller.dart';
import 'package:tasky/feature/reflection/daily_reflection_dialog.dart';
import 'package:tasky/feature/templates/templates_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark();
    return ChangeNotifierProvider(
      create: (BuildContext context) => HomeController()..init(),
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (context) {
            return SizedBox(
              height: 48,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  AdService().showInterstitialIfReady();
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTask()),
                  );
                  if (result != null && result && context.mounted) {
                    context.read<HomeController>().loadTaskData();
                  }
                },
                label: const Text(
                  'Add New Task',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.add_rounded, size: 22),
                backgroundColor: const Color(0xff15B86C),
                foregroundColor: const Color(0xffFFFCFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            );
          },
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top User Bar + Streak Pill
                    Consumer<HomeController>(
                      builder: (context, controller, child) {
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.transparent,
                              backgroundImage: controller.userImagePath == null
                                  ? const AssetImage('assets/image/Thumbnail.png')
                                  : FileImage(File(controller.userImagePath!))
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${controller.username ?? 'Explorer'} 👋',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    controller.motivationQuoteKey ??
                                        'One task at a time. One step closer.',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                            ),
                            // Daily Streak Pill (Interactive Share Story)
                            ValueListenableBuilder<int>(
                              valueListenable: StreakService.streakNotifier,
                              builder: (context, streak, _) {
                                return GestureDetector(
                                  onTap: () {
                                    ShareStreakModal.show(
                                      context,
                                      userName: controller.username ?? 'Explorer',
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFF59E0B)
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🔥',
                                            style: TextStyle(fontSize: 14)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$streak ${streak == 1 ? 'Day' : 'Days'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFFF59E0B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Daily Activity Rings Card
                    const ActivityRingsCard(),

                    const SizedBox(height: 12),

                    // Greeting Header
                    Text(
                      'Yuhuu, your work is',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Row(
                      children: [
                        Text(
                          'almost done! ',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        SvgPicture.asset(
                          'assets/image/waving_hand.svg',
                          width: 28,
                          height: 28,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress Overview
                    const AchievedTasksWidget(),

                    const SizedBox(height: 14),

                    // AI Daily Roadmap Banner
                    Consumer<HomeController>(
                      builder: (context, controller, child) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        final pending = controller.allTasks
                            .where((t) => !t.isDone)
                            .toList();

                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E3A2F),
                                      const Color(0xFF142721)
                                    ]
                                  : [
                                      const Color(0xFFE8F8F0),
                                      const Color(0xFFD3F2E3)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF15B86C)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                AIDailyPlannerSheet.show(
                                  context,
                                  pendingTasks: pending,
                                  userName: controller.username,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF15B86C),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text('✨',
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'AI Daily Roadmap',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? const Color(0xFF4ADE80)
                                                  : const Color(0xFF0F7644),
                                            ),
                                          ),
                                          Text(
                                            'Generate personalized schedule & coaching',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: isDark
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFF0F7644),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Productivity Tools Shortcuts Row (Eisenhower Matrix + Habits)
                    Row(
                      children: [
                        Expanded(
                          child: _buildToolShortcut(
                            context,
                            icon: Icons.dashboard_customize_outlined,
                            title: 'Eisenhower',
                            subtitle: '4-Quadrant Grid',
                            color: const Color(0xFF3B82F6),
                            onTap: () {
                              AdService().showInterstitialIfReady();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EisenhowerMatrixScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildToolShortcut(
                            context,
                            icon: Icons.calendar_view_week_rounded,
                            title: 'Habits',
                            subtitle: 'Consistency Heatmap',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {
                              AdService().showInterstitialIfReady();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HabitsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Productivity Tools Row 2 (Focus Garden + 1-Click Templates)
                    Row(
                      children: [
                        Expanded(
                          child: _buildToolShortcut(
                            context,
                            icon: Icons.park_rounded,
                            title: 'Garden & Badges',
                            subtitle: 'Trees & Trophies',
                            color: const Color(0xFF10B981),
                            onTap: () {
                              AdService().showInterstitialIfReady();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FocusGardenScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildToolShortcut(
                            context,
                            icon: Icons.copy_all_rounded,
                            title: '1-Click Packs',
                            subtitle: 'Instant Routines',
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              AdService().showInterstitialIfReady();
                              TemplatesSheet.show(
                                context,
                                onApplied: () {
                                  context.read<HomeController>().loadTaskData();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Evening Reflection Pill Button
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        AdService().showInterstitialIfReady();
                        DailyReflectionDialog.show(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                              : const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🌙', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Evening Reflection',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Review your day and earn +15💧 garden drops',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // High Priority Shortcut
                    const HighPriorityTasksWidget(),

                    const SizedBox(height: 14),

                    // AdMob Banner Ad
                    const Center(
                      child: TaskyBannerAdWidget(
                        margin: EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tasks Header & Filter
                    Text(
                      "My Tasks",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 10),

                    // Category Filter Horizontal Carousel
                    Consumer<HomeController>(
                      builder: (context, controller, child) {
                        final categories = [
                          'All',
                          ...TaskCategory.all.map((c) => c.id),
                        ];

                        return SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final catId = categories[index];
                              final isSelected =
                                  controller.selectedCategory.toLowerCase() ==
                                      catId.toLowerCase();
                              final count = controller.countForCategory(catId);
                              final categoryObj = catId == 'All'
                                  ? null
                                  : TaskCategory.fromId(catId);

                              return FilterChip(
                                showCheckmark: false,
                                label: Text(
                                  catId == 'All'
                                      ? 'All ($count)'
                                      : '${categoryObj?.nameEn ?? catId} ($count)',
                                ),
                                avatar: catId == 'All'
                                    ? Icon(
                                        Icons.grid_view_rounded,
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : (Theme.of(context).brightness == Brightness.dark
                                                ? const Color(0xffB0B0B0)
                                                : const Color(0xff5A6862)),
                                      )
                                    : Icon(
                                        categoryObj?.icon,
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : categoryObj?.color,
                                      ),
                                selected: isSelected,
                                selectedColor: Theme.of(context).colorScheme.primary,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xffB0B0B0)
                                          : const Color(0xff3A4640)),
                                ),
                                onSelected: (_) {
                                  controller.selectCategory(catId);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SliverTasksList(
                textMessage:
                    'There are no tasks yet... Click + to add your first task ✍️',
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 60),
                  child: Center(
                    child: TaskyBannerAdWidget(
                      margin: EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolShortcut(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
