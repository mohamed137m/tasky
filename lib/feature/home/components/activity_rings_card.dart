import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tasky/core/services/activity_rings_service.dart';
import 'package:tasky/core/theme/theme_controller.dart';

class ActivityRingsCard extends StatelessWidget {
  const ActivityRingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark();
    final theme = Theme.of(context);

    return ValueListenableBuilder<ActivityRingsData>(
      valueListenable: ActivityRingsService.ringsNotifier,
      builder: (context, data, _) {
        final allClosed = data.isAllRingsClosed;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: allClosed
                  ? const Color(0xFF15B86C).withValues(alpha: 0.6)
                  : theme.colorScheme.outlineVariant,
              width: allClosed ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : const Color(0xFF3B82F6).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 3 Concentric Activity Rings
              SizedBox(
                width: 104,
                height: 104,
                child: CustomPaint(
                  painter: _TripleRingsPainter(
                    taskProgress: data.tasksProgress,
                    habitProgress: data.habitsProgress,
                    focusProgress: data.focusProgress,
                    isDark: isDark,
                  ),
                  child: Center(
                    child: allClosed
                        ? const Text('🏆', style: TextStyle(fontSize: 22))
                        : Icon(
                            Icons.bolt_rounded,
                            color: isDark ? Colors.white70 : const Color(0xFF15B86C),
                            size: 24,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Metric Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Activity Rings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (allClosed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15B86C).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Closed! 🎉',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15B86C),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRingLegend(
                      theme: theme,
                      color: const Color(0xFF15B86C),
                      label: 'Tasks',
                      value: '${data.tasksCompleted}/${data.tasksGoal}',
                      isDone: data.tasksCompleted >= data.tasksGoal,
                    ),
                    const SizedBox(height: 5),
                    _buildRingLegend(
                      theme: theme,
                      color: const Color(0xFF8B5CF6),
                      label: 'Habits',
                      value: '${data.habitsCompleted}/${data.habitsGoal}',
                      isDone: data.habitsCompleted >= data.habitsGoal,
                    ),
                    const SizedBox(height: 5),
                    _buildRingLegend(
                      theme: theme,
                      color: const Color(0xFF3B82F6),
                      label: 'Focus',
                      value: '${data.focusMinutes}/${data.focusMinutesGoal}m',
                      isDone: data.focusMinutes >= data.focusMinutesGoal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRingLegend({
    required ThemeData theme,
    required Color color,
    required String label,
    required String value,
    required bool isDone,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.secondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDone ? color : null,
          ),
        ),
        if (isDone) ...[
          const SizedBox(width: 4),
          Icon(Icons.check_circle_rounded, size: 13, color: color),
        ],
      ],
    );
  }
}

class _TripleRingsPainter extends CustomPainter {
  final double taskProgress;
  final double habitProgress;
  final double focusProgress;
  final bool isDark;

  const _TripleRingsPainter({
    required this.taskProgress,
    required this.habitProgress,
    required this.focusProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;
    const ringSpacing = 3.0;

    // Ring 1 (Outer - Tasks)
    final r1 = (size.width / 2) - strokeWidth / 2;
    _drawRing(
      canvas,
      center,
      r1,
      strokeWidth,
      taskProgress,
      const Color(0xFF15B86C),
    );

    // Ring 2 (Middle - Habits)
    final r2 = r1 - strokeWidth - ringSpacing;
    _drawRing(
      canvas,
      center,
      r2,
      strokeWidth,
      habitProgress,
      const Color(0xFF8B5CF6),
    );

    // Ring 3 (Inner - Focus Minutes)
    final r3 = r2 - strokeWidth - ringSpacing;
    _drawRing(
      canvas,
      center,
      r3,
      strokeWidth,
      focusProgress,
      const Color(0xFF3B82F6),
    );
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
    double progress,
    Color color,
  ) {
    final bgPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.18 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TripleRingsPainter oldDelegate) {
    return oldDelegate.taskProgress != taskProgress ||
        oldDelegate.habitProgress != habitProgress ||
        oldDelegate.focusProgress != focusProgress ||
        oldDelegate.isDark != isDark;
  }
}
