import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/firestore_sync_service.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';

class TaskTemplateBundle {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;
  final int priority;
  final List<String> taskTitles;

  const TaskTemplateBundle({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.priority,
    required this.taskTitles,
  });
}

class TemplatesService {
  static final TemplatesService _instance = TemplatesService._internal();
  factory TemplatesService() => _instance;
  TemplatesService._internal();

  static const List<TaskTemplateBundle> presets = [
    TaskTemplateBundle(
      id: 'morning_routine',
      title: 'Morning Miracle Routine',
      description: 'Prime your mind and body for peak daily focus and energy',
      icon: '🌅',
      category: 'personal',
      priority: 2,
      taskTitles: [
        'Hydrate with 500ml water & electrolytes',
        '10-minute mindfulness meditation or breathwork',
        'Light physical stretching or 15m walk',
        'Review top 3 core priorities for today in Tasky',
      ],
    ),
    TaskTemplateBundle(
      id: 'deep_work_sprint',
      title: 'Deep Work Sprint',
      description: 'Zero distractions protocol for high-leverage execution',
      icon: '🎯',
      category: 'work',
      priority: 3,
      taskTitles: [
        'Close all unnecessary browser tabs & silence notifications',
        'Define single objective for the focus block',
        'Complete 50m Pomodoro deep work sprint',
        'Document output and organize next steps',
      ],
    ),
    TaskTemplateBundle(
      id: 'study_exam_sprint',
      title: 'Exam & Study Sprint',
      description: 'Scientifically proven active recall and spaced repetition',
      icon: '📚',
      category: 'study',
      priority: 3,
      taskTitles: [
        'Review high-yield flashcards & lecture notes',
        'Solve 5 practice problems without looking at solutions',
        'Create a 1-page visual summary sheet',
        'Teach core concepts out loud (Feynman Technique)',
      ],
    ),
    TaskTemplateBundle(
      id: 'interview_prep',
      title: 'Job Interview Prep',
      description: 'Thorough preparation to ace any technical or culture fit interview',
      icon: '💼',
      category: 'work',
      priority: 4,
      taskTitles: [
        'Deep dive into company product, values and recent news',
        'Rehearse 90-second professional elevator pitch',
        'Prepare 3 STAR-method stories (Situation, Task, Action, Result)',
        'Formulate 5 thoughtful questions to ask the interviewers',
      ],
    ),
    TaskTemplateBundle(
      id: 'travel_packing',
      title: 'Travel & Packing Checklist',
      description: 'Stress-free trip essentials so you never leave anything behind',
      icon: '✈️',
      category: 'personal',
      priority: 2,
      taskTitles: [
        'Passport, ID, visa and offline booking confirmations',
        'All chargers, cables, universal adapter and powerbank',
        'Daily medications, hygiene kit and travel toiletries',
        'Weather-appropriate outfits and comfortable shoes',
      ],
    ),
  ];

  Future<int> applyTemplate(TaskTemplateBundle template) async {
    final tasks = HiveStorageManger().loadTasks();
    int baseId = tasks.isEmpty
        ? 1
        : (tasks.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

    int count = 0;
    final now = DateTime.now();

    for (final title in template.taskTitles) {
      final task = TaskModels(
        id: baseId++,
        taskName: title,
        taskDescription: 'Created from ${template.title} template',
        isHighPriority: template.priority >= 3,
        priority: template.priority,
        category: template.category,
        dueDate: now.add(const Duration(hours: 4)),
        createdAt: now,
      );
      tasks.add(task);
      count++;
    }

    await HiveStorageManger().saveTasks(tasks);
    FirestoreSyncService().syncToCloud();
    return count;
  }
}
