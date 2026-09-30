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
    return Consumer<HomeController>(
      builder: (BuildContext context, controller, Widget? child) {
        return Container(
          padding: EdgeInsets.all(10),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Priority Tasks',
                      style: TextStyle(color: Color(0xff15B86C), fontSize: 14),
                    ),
                    ...controller.tasks
                        .where((e) => e.isHighPriority)
                        .toList()
                        .reversed
                        .take(
                          controller.tasks.reversed
                                      .where((e) => e.isHighPriority)
                                      .length >
                                  4
                              ? 4
                              : controller.tasks.reversed
                                    .where((e) => e.isHighPriority)
                                    .length,
                        )
                        .map((element) {
                          return Row(
                            children: [
                              CustomCheckBoxWidget(
                                value: element.isDone,
                                onChanged: (value) async {
                                  final index = controller.tasks.indexWhere((
                                    e,
                                  ) {
                                    return e.id == element.id;
                                  });
                                  controller.doneTask(value, index);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  maxLines: 1,
                                  element.taskName,
                                  style: element.isDone
                                      ? Theme.of(
                                          context,
                                        ).textTheme.displayMedium
                                      : Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          );
                        }),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return HighPriorityScreen();
                        },
                      ),
                    );
                    controller.loadTaskData();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xff6E6E6E), width: 1),
                    ),
                    child: SvgPicture.asset(
                      'assets/image/arrow_up_right.svg',
                      colorFilter: ColorFilter.mode(
                        ThemeController.isDark()
                            ? Color(0xffC6C6C6)
                            : Color(0xff3A4640),
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
