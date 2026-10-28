import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasky/add_tasks/add_task_controller.dart';
import 'package:tasky/core/constants/task_categories.dart';
import 'package:tasky/core/widgets/custom_text_form_field.dart';
import 'package:tasky/feature/home/components/smart_quick_add_bar.dart';
import 'package:tasky/feature/templates/templates_sheet.dart';

class AddTask extends StatelessWidget {
  const AddTask({super.key});

  @override
  Widget build(BuildContext _) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => AddTaskController(),
      builder: (context, child) {
        final controller = context.watch<AddTaskController>();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            title: const Text('New Task'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Text('📋', style: TextStyle(fontSize: 18)),
                tooltip: '1-Click Templates',
                onPressed: () {
                  TemplatesSheet.show(context, onApplied: () {
                    Navigator.pop(context, true);
                  });
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Form(
                key: controller.key,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Smart Natural Language Input
                            SmartQuickAddBar(
                              onParsed: (result) {
                                controller.applySmartParseResult(result);
                              },
                            ),

                            // Task Name
                            CustomTextFormField(
                              controllers: controller.taskNameController,
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please Enter Task Name';
                                }
                                return null;
                              },
                              hintText: 'e.g., Finish project proposal & submit',
                              textTitle: 'Task Name',
                            ),

                            const SizedBox(height: 10),

                            // AI Breakdown Button
                            InkWell(
                              onTap: controller.isGeneratingAI
                                  ? null
                                  : () => controller.generateSubtasksWithAI(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [const Color(0xFF1E3A2F), const Color(0xFF142721)]
                                        : [const Color(0xFFE8F8F0), const Color(0xFFD3F2E3)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF15B86C).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (controller.isGeneratingAI)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFF15B86C),
                                          ),
                                        ),
                                      )
                                    else
                                      const Text('🪄', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      controller.isGeneratingAI
                                          ? 'AI is breaking down task...'
                                          : 'Magic AI Task Breakdown',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF0F7644),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Categories
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: TaskCategory.all.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final cat = TaskCategory.all[index];
                                  final isSelected = controller.category == cat.id;
                                  return ChoiceChip(
                                    selected: isSelected,
                                    showCheckmark: false,
                                    avatar: Icon(
                                      cat.icon,
                                      size: 16,
                                      color: isSelected ? Colors.white : cat.color,
                                    ),
                                    label: Text(cat.nameEn),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? Colors.white70 : const Color(0xFF3A4640)),
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    selectedColor: cat.color,
                                    backgroundColor: isDark ? const Color(0xFF242C28) : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSelected
                                            ? cat.color
                                            : (isDark ? Colors.white12 : Colors.black12),
                                      ),
                                    ),
                                    onSelected: (selected) {
                                      if (selected) controller.setCategory(cat.id);
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Priority Matrix
                            Text(
                              'Priority',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildPriorityOption(
                                  context: context,
                                  title: 'Low',
                                  level: 1,
                                  color: Colors.blue,
                                  current: controller.priority,
                                  onTap: () => controller.setPriority(1),
                                ),
                                const SizedBox(width: 6),
                                _buildPriorityOption(
                                  context: context,
                                  title: 'Medium',
                                  level: 2,
                                  color: Colors.amber,
                                  current: controller.priority,
                                  onTap: () => controller.setPriority(2),
                                ),
                                const SizedBox(width: 6),
                                _buildPriorityOption(
                                  context: context,
                                  title: 'High',
                                  level: 3,
                                  color: Colors.orange,
                                  current: controller.priority,
                                  onTap: () => controller.setPriority(3),
                                ),
                                const SizedBox(width: 6),
                                _buildPriorityOption(
                                  context: context,
                                  title: 'Urgent',
                                  level: 4,
                                  color: Colors.red,
                                  current: controller.priority,
                                  onTap: () => controller.setPriority(4),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Due Date & Time
                            Text(
                              'Due Date & Time',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final selected = await showDatePicker(
                                        context: context,
                                        initialDate: controller.dueDate ?? DateTime.now(),
                                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                                      );
                                      if (selected != null) {
                                        controller.setDueDate(selected);
                                      }
                                    },
                                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                                    label: Text(
                                      controller.dueDate == null
                                          ? 'Select Date'
                                          : DateFormat('MMM dd, yyyy').format(controller.dueDate!),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final selected = await showTimePicker(
                                        context: context,
                                        initialTime: controller.dueTime ?? TimeOfDay.now(),
                                      );
                                      if (selected != null) {
                                        controller.setDueTime(selected);
                                      }
                                    },
                                    icon: const Icon(Icons.access_time, size: 16),
                                    label: Text(
                                      controller.dueTime == null
                                          ? 'Select Time'
                                          : controller.dueTime!.format(context),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (controller.dueDate != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF15B86C).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF15B86C).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.notifications_active_rounded,
                                      size: 16,
                                      color: Color(0xFF15B86C),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Smart notification will remind you at scheduled time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? const Color(0xFF4ADE80)
                                              : const Color(0xFF0F7644),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Subtasks Checklist
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtasks (${controller.subtasks.length})',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                if (controller.subtasks.isNotEmpty)
                                  Text(
                                    '${controller.subtasks.where((s) => s.isDone).length}/${controller.subtasks.length} done',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Add subtask input row
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.subtaskInputController,
                                    decoration: InputDecoration(
                                      hintText: 'Add a subtask...',
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF242C28) : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark ? Colors.white12 : const Color(0xFFD1DAD6),
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (val) => controller.addSubtask(val),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: () {
                                    controller.addSubtask(
                                      controller.subtaskInputController.text,
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 20),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF15B86C),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            // Subtask list
                            if (controller.subtasks.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.subtasks.length,
                                  itemBuilder: (context, index) {
                                    final sub = controller.subtasks[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E2622) : const Color(0xFFF3F5F4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        leading: Checkbox(
                                          value: sub.isDone,
                                          onChanged: (_) => controller.toggleSubtask(index),
                                          activeColor: const Color(0xFF15B86C),
                                        ),
                                        title: Text(
                                          sub.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            decoration: sub.isDone ? TextDecoration.lineThrough : null,
                                            color: sub.isDone
                                                ? (isDark ? const Color(0xff757575) : const Color(0xff8A9791))
                                                : (isDark ? const Color(0xffF5F5F5) : const Color(0xff161F1B)),
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                                          onPressed: () => controller.removeSubtask(index),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Description
                            CustomTextFormField(
                              maxLines: 4,
                              controllers: controller.taskDescriptionController,
                              hintText: 'Additional notes or context for this task...',
                              textTitle: 'Task Description (Optional)',
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),

                    // Add Task Button
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.addTasks(context);
                      },
                      label: const Text(
                        'Create Task',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(Icons.check),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15B86C),
                        foregroundColor: Colors.white,
                        fixedSize: Size(MediaQuery.of(context).size.width, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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

  Widget _buildPriorityOption({
    required BuildContext context,
    required String title,
    required int level,
    required Color color,
    required int current,
    required VoidCallback onTap,
  }) {
    final isSelected = current == level;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF242C28) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : (isDark ? const Color(0xffB0B0B0) : const Color(0xff5A6862)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
