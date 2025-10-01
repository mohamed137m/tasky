import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/feature/home/home_controller.dart';

class AchievedTasksWidget extends StatelessWidget {
  const AchievedTasksWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context,HomeController controller, Widget? child)=>Container(
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
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: controller.percent,
                      backgroundColor: Color(0xff6D6D6D),
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation(Color(0xff15B86C)),
                    ),
                  ),
                ),
                Text(
                  "${((controller.percent * 100).toInt())}%",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
