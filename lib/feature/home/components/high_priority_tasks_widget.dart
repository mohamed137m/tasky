import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/core/widgets/custom_check_box_widget.dart';
import 'package:tasky/feature/high_priority/high_priority_screen.dart';
import 'package:tasky/feature/home/home_controller.dart';

class HighPriorityTasksWidget extends StatelessWidget {
  const HighPriorityTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark();

    return Consumer<HomeController>(
      builder: (BuildContext context, controller, Widget? child) {
        final highPriorityList =
            controller.tasks.where((e) => e.isHighPriority).toList().reversed;

        return Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1.2,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.flag_rounded,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'High Priority Tasks',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xff4ADE80)
                                : const Color(0xff15B86C),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (highPriorityList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No high priority tasks! 🎉',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    else
                      ...highPriorityList.take(4).map((element) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              CustomCheckBoxWidget(
                                value: element.isDone,
                                onChanged: (value) async {
                                  final index = controller.tasks.indexWhere((e) {
                                    return e.id == element.id;
                                  });
                                  controller.doneTask(value, index);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  element.taskName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: element.isDone
                                      ? Theme.of(context).textTheme.displayMedium
                                      : Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const HighPriorityScreen();
                        },
                      ),
                    );
                    controller.loadTaskData();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/image/arrow_up_right.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
