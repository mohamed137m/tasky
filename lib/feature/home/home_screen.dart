import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tasky/feature/home/home_controller.dart';
import 'package:tasky/add_tasks/add_task.dart';
import 'package:tasky/feature/home/components/achieved_tasks_widget.dart';
import 'package:tasky/feature/home/components/high_priority_tasks_widget.dart';
import 'package:tasky/feature/home/components/sliver_tasks_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => HomeController()..init(),
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (context) {
            return SizedBox(
              height: 44,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddTask()),
                  );
                  if (result != null && result && context.mounted) {
                    context.read<HomeController>().loadTaskData();
                  }
                },
                label: Text('Add New Task'),
                icon: Icon(Icons.add),
                backgroundColor: Color(0xff15B86C),
                foregroundColor: Color(0xffFFFCFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            );
          },
        ),

        body: Padding(
          padding: const EdgeInsets.all(12),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Selector<HomeController, String?>(
                      selector: (BuildContext context, controller) =>
                          controller.userImagePath,
                      builder:
                          (
                            BuildContext context,
                            String? userImagePath,
                            Widget? child,
                          ) {
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 21,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: userImagePath == null
                                      ? AssetImage('assets/image/Thumbnail.png')
                                      : FileImage(File(userImagePath)),
                                ),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Selector<HomeController, String?>(
                                      selector:
                                          (
                                            BuildContext context,
                                            HomeController controller,
                                          ) => controller.username,
                                      builder:
                                          (
                                            BuildContext context,
                                            String? username,
                                            Widget? child,
                                          ) => Text(
                                            'Good Evening $username',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                    ),
                                    Selector<HomeController, String?>(
                                      builder:
                                          (
                                            BuildContext context,
                                            String? motivationQuoteKey,
                                            Widget? child,
                                          ) => Text(
                                            motivationQuoteKey ??
                                                'One task at a time.One step closer.',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                      selector:
                                          (BuildContext context, controller) =>
                                              controller.motivationQuoteKey,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Yuhuu ,Your work Is',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Row(
                      children: [
                        Text(
                          'almost done ! ',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        SvgPicture.asset(
                          'assets/image/waving_hand.svg',
                          width: 32,
                          height: 32,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    AchievedTasksWidget(),
                    SizedBox(height: 16),

                    HighPriorityTasksWidget(),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 16),
                      child: Text(
                        "My Tasks",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              SliverTasksList(
                textMessage:
                    'There are no tasks yet... Click + to add the first task ✍️',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
