import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/task_categories.dart';
import 'package:tasky/core/enum/enum_menu_actions_item.dart';
import 'package:tasky/core/services/activity_rings_service.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/core/services/firestore_sync_service.dart';
import 'package:tasky/core/services/garden_service.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/core/services/streak_service.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/core/widgets/custom_check_box_widget.dart';
import 'package:tasky/core/widgets/custom_text_form_field.dart';

class TaskListItem extends StatefulWidget {
  const TaskListItem({
    super.key,
    required this.models,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });

  final TaskModels models;
  final Function(bool? value) onChanged;
  final Function(int id) onDelete;
  final Function onEdit;

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  late ConfettiController _confettiController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerCompletionFeedback() {
    HapticFeedback.mediumImpact();
    _confettiController.play();
    StreakService().recordTaskCompleted();
    GardenService().addWaterDrops(10);
    ActivityRingsService().refreshRings();
    AdService().showInterstitialIfReady();
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 4:
        return const Color(0xFFEF4444);
      case 3:
        return const Color(0xFFF97316);
      case 2:
        return const Color(0xFFEAB308);
      case 1:
      default:
        return const Color(0xFF10B981);
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 4:
        return 'Urgent';
      case 3:
        return 'High';
      case 2:
        return 'Medium';
      case 1:
      default:
        return 'Low';
    }
  }

  String _formatDueDate(DateTime? date, String? time) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (target == today) {
      dateStr = 'Today';
    } else if (target == today.add(const Duration(days: 1))) {
      dateStr = 'Tomorrow';
    } else if (target == today.subtract(const Duration(days: 1))) {
      dateStr = 'Yesterday';
    } else {
      dateStr = DateFormat('MMM d').format(date);
    }

    if (time != null && time.isNotEmpty) {
      return '$dateStr • $time';
    }
    return dateStr;
  }

  Future<void> _toggleSubtask(int subtaskIndex, bool value) async {
    final subtasks = widget.models.subtasks;
    if (subtaskIndex < 0 || subtaskIndex >= subtasks.length) return;

    subtasks[subtaskIndex].isDone = value;
    widget.models.subtasks = subtasks;

    final tasks = HiveStorageManger().loadTasks();
    final idx = tasks.indexWhere((e) => e.id == widget.models.id);
    if (idx != -1) {
      tasks[idx] = widget.models;

      // If all subtasks are finished and main task is not done, complete it!
      final allDone = subtasks.isNotEmpty && subtasks.every((s) => s.isDone);
      if (allDone && !widget.models.isDone) {
        widget.models.isDone = true;
        tasks[idx].isDone = true;
        NotificationService().cancelTaskReminder(widget.models.id);
        _triggerCompletionFeedback();
        widget.onChanged(true);
      }

      await HiveStorageManger().saveTasks(tasks);
      FirestoreSyncService().syncToCloud();
    }

    setState(() {});
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Do you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete(widget.models.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.models;
    final category = TaskCategory.fromId(model.category);
    final priorityColor = _getPriorityColor(model.priority);
    final hasSubtasks = model.subtasks.isNotEmpty;
    final isDark = ThemeController.isDark();

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: model.isOverdue
                  ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                  : isDark
                      ? Colors.transparent
                      : const Color(0xffD1DAD6),
              width: model.isOverdue ? 1.8 : 1.5,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Task Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Priority Indicator Dot
                    Container(
                      width: 4,
                      height: 38,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Checkbox
                    CustomCheckBoxWidget(
                      value: model.isDone,
                      onChanged: (value) {
                        if (value == true) {
                          _triggerCompletionFeedback();
                        }
                        widget.onChanged(value);
                      },
                    ),
                    const SizedBox(width: 8),
                    // Task Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            model.taskName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: model.isDone
                                ? Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    )
                                : Theme.of(context).textTheme.titleMedium,
                          ),
                          if (model.taskDescription.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              model.taskDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: model.isDone
                                  ? Theme.of(context).textTheme.displayMedium
                                  : Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Menu actions
                    PopupMenuButton<EnumMenuActionsItem>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark
                            ? (model.isDone
                                ? const Color(0xffA0A0A0)
                                : const Color(0xffFFFCFC))
                            : (model.isDone
                                ? const Color(0xff6A6A6A)
                                : const Color(0xff161F1B)),
                      ),
                      onSelected: (value) async {
                        switch (value) {
                          case EnumMenuActionsItem.markAsDone:
                            final newVal = !model.isDone;
                            if (newVal) {
                              _triggerCompletionFeedback();
                            }
                            widget.onChanged(newVal);
                            break;
                          case EnumMenuActionsItem.delete:
                            await _showAlertDialog(context);
                            break;
                          case EnumMenuActionsItem.edit:
                            final result =
                                await _showBottomSheet(context, model);
                            if (result == true) {
                              widget.onEdit();
                            }
                            break;
                        }
                      },
                      itemBuilder: (context) => EnumMenuActionsItem.values
                          .map(
                            (e) => PopupMenuItem<EnumMenuActionsItem>(
                              value: e,
                              child: Text(
                                e == EnumMenuActionsItem.markAsDone
                                    ? (model.isDone
                                        ? "Mark as To Do"
                                        : "Mark as Done")
                                    : e.name,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

              // Badges & Metadata Row (Category, Due Date, Subtask Count)
              Padding(
                padding: const EdgeInsets.only(left: 22, right: 12, bottom: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Category Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, size: 12, color: category.color),
                          const SizedBox(width: 4),
                          Text(
                            category.nameEn,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: category.color,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Priority Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPriorityLabel(model.priority),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),

                    // Due Date / Overdue Tag
                    if (model.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: model.isOverdue
                              ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              model.isOverdue
                                  ? Icons.warning_amber_rounded
                                  : Icons.calendar_today_outlined,
                              size: 11,
                              color: model.isOverdue
                                  ? const Color(0xFFEF4444)
                                  : (isDark ? const Color(0xffB0B0B0) : const Color(0xff5A6862)),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDueDate(model.dueDate, model.dueTime),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: model.isOverdue
                                    ? const Color(0xFFEF4444)
                                    : (isDark ? const Color(0xffF5F5F5) : const Color(0xff161F1B)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Subtask toggle button
                    if (hasSubtasks)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15B86C).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.checklist_rounded,
                                size: 12,
                                color: Color(0xFF15B86C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${model.completedSubtasksCount}/${model.subtasks.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15B86C),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: const Color(0xFF15B86C),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Subtasks Progress Bar (if has subtasks)
              if (hasSubtasks)
                Padding(
                  padding: const EdgeInsets.only(left: 22, right: 16, bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: model.subtasksProgress,
                      minHeight: 3,
                      backgroundColor:
                          isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF15B86C)),
                    ),
                  ),
                ),

              // Expandable Subtask items list
              if (hasSubtasks && _isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 14, bottom: 10),
                  child: Column(
                    children: [
                      const Divider(height: 12, thickness: 0.5),
                      ...model.subtasks.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final subtask = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: subtask.isDone,
                                  activeColor: const Color(0xFF15B86C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      _toggleSubtask(idx, val);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  subtask.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    decoration: subtask.isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: subtask.isDone
                                        ? (isDark ? const Color(0xff757575) : const Color(0xff8A9791))
                                        : (isDark ? const Color(0xffF5F5F5) : const Color(0xff161F1B)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Confetti explosion
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFF15B86C),
              Color(0xFF3B82F6),
              Color(0xFFF59E0B),
              Color(0xFFEC4899),
              Color(0xFF8B5CF6),
            ],
            numberOfParticles: 20,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }

  Future<bool?> _showBottomSheet(BuildContext context, TaskModels model) async {
    final TextEditingController taskNameController = TextEditingController(
      text: model.taskName,
    );
    final TextEditingController taskDescriptionController =
        TextEditingController(text: model.taskDescription);
    final GlobalKey<FormState> key = GlobalKey<FormState>();
    int priority = model.priority;
    String category = model.category;
    DateTime? dueDate = model.dueDate;
    String? dueTime = model.dueTime;

    return showModalBottomSheet<bool>(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: key,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Edit Task',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controllers: taskNameController,
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter task name';
                          }
                          return null;
                        },
                        hintText: 'Task name',
                        textTitle: 'Task Name',
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        maxLines: 3,
                        controllers: taskDescriptionController,
                        hintText: 'Task description',
                        textTitle: 'Description',
                      ),
                      const SizedBox(height: 16),
                      // Category selection
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: TaskCategory.all.map((c) {
                          final isSelected = c.id == category;
                          return ChoiceChip(
                            label: Text(c.nameEn),
                            avatar: Icon(
                              c.icon,
                              size: 14,
                              color: isSelected ? Colors.white : c.color,
                            ),
                            selected: isSelected,
                            selectedColor: c.color,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => category = c.id);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Priority matrix
                      Text(
                        'Priority',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (int p = 1; p <= 4; p++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: InkWell(
                                  onTap: () => setState(() => priority = p),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: priority == p
                                          ? _getPriorityColor(p)
                                          : _getPriorityColor(p).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _getPriorityColor(p),
                                        width: priority == p ? 2 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getPriorityLabel(p),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: priority == p
                                              ? Colors.white
                                              : _getPriorityColor(p),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Date and Time picker
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: dueDate ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() => dueDate = picked);
                                }
                              },
                              icon: const Icon(Icons.calendar_today_outlined, size: 16),
                              label: Text(
                                dueDate == null
                                    ? 'Set Due Date'
                                    : DateFormat('MMM d').format(dueDate!),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null && context.mounted) {
                                  setState(() {
                                    dueTime = time.format(context);
                                  });
                                }
                              },
                              icon: const Icon(Icons.access_time, size: 16),
                              label: Text(
                                dueTime ?? 'Set Time',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (dueDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_active_rounded,
                              size: 14,
                              color: Color(0xFF15B86C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reminder will update automatically',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (key.currentState?.validate() ?? false) {
                            final tasks = HiveStorageManger().loadTasks();
                            final updatedModel = TaskModels(
                              id: model.id,
                              taskName: taskNameController.text.trim(),
                              taskDescription:
                                  taskDescriptionController.text.trim(),
                              isHighPriority: priority >= 3,
                              isDone: model.isDone,
                              category: category,
                              priority: priority,
                              dueDate: dueDate,
                              dueTime: dueTime,
                              rawSubtasks: model.rawSubtasks,
                              createdAt: model.createdAt,
                              completedAt: model.completedAt,
                            );

                            final index = tasks.indexWhere(
                              (e) => e.id == model.id,
                            );
                            if (index != -1) {
                              tasks[index] = updatedModel;
                              await HiveStorageManger().saveTasks(tasks);
                              FirestoreSyncService().syncToCloud();
                              if (!updatedModel.isDone) {
                                NotificationService().scheduleTaskReminder(updatedModel);
                              } else {
                                NotificationService().cancelTaskReminder(updatedModel.id);
                              }
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Save Changes'),
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
            );
          },
        );
      },
    );
  }
}
