import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/feature/home/home_controller.dart';

class AchievedTasksWidget extends StatelessWidget {
  const AchievedTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark();

    return Consumer<HomeController>(
      builder: (BuildContext context, HomeController controller, Widget? child) =>
          Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achieved Tasks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.tootleDoneTask} Out of ${controller.tootleTask} Done',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -pi / 2,
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: controller.percent,
                      backgroundColor:
                          isDark ? const Color(0xff353535) : const Color(0xffE2E8F0),
                      strokeWidth: 5.5,
                      strokeCap: StrokeCap.round,
                      valueColor: const AlwaysStoppedAnimation(Color(0xff15B86C)),
                    ),
                  ),
                ),
                Text(
                  "${((controller.percent * 100).toInt())}%",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
