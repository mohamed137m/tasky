import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tasky/core/theme/theme_controller.dart';

class AchievedTasksWidget extends StatelessWidget {
  const AchievedTasksWidget({
    super.key,
    required this.tootleDoneTask,
    required this.tootleTask,
    required this.percent,
  });
  final int tootleDoneTask;
  final int tootleTask;
  final double percent;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeController.isDark()
              ? Colors.transparent
              : Color(0xffD1DAD6),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                'Achieved Tasks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 4),
              Text(
                '$tootleDoneTask Out of $tootleTask Done',
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
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: percent,
                    backgroundColor: Color(0xff6D6D6D),
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation(Color(0xff15B86C)),
                  ),
                ),
              ),
              Text(
                "${((percent * 100).toInt())}%",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
