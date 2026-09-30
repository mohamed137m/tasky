import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/add_tasks/add_task_controller.dart';
import 'package:tasky/core/widgets/custom_text_form_field.dart';

class AddTask extends StatelessWidget {
  const AddTask({super.key});

  @override
  Widget build(BuildContext _) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => AddTaskController(),
      builder: (context, child) {
        final controller = context.watch<AddTaskController>();
        return Scaffold(
          appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            title: Text('New Task'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Form(
                key: controller.key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextFormField(
                              controllers: controller.taskNameController,
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please Enter Task Name';
                                }
                                return null;
                              },
                              hintText: 'Finish UI design for login screen',
                              textTitle: 'Task Name',
                            ),
                            SizedBox(height: 28),
                            CustomTextFormField(
                              maxLines: 6,
                              controllers: controller.taskDescriptionController,
                              hintText:
                                  'Finish onboarding UI and hand off to devs by Thursday.',
                              textTitle: 'Task Description',
                            ),

                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'High Priority',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Consumer<AddTaskController>(
                                  builder:
                                      (
                                        BuildContext context,
                                        value,
                                        Widget? child,
                                      ) {
                                        return Switch(
                                          value: value.isHighPriority,
                                          onChanged: (bool value) {
                                            controller.toggle(value);
                                          },
                                        );
                                      },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.addTasks(context);
                      },
                      label: Text('Add Task'),
                      icon: Icon(Icons.add),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(MediaQuery.of(context).size.width, 42),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
