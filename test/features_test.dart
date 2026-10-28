import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/Models/sub_task_model.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/task_categories.dart';
import 'package:tasky/core/models/habit_item.dart';
import 'package:tasky/core/services/ai_service.dart';
import 'package:tasky/core/services/habits_service.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/services/streak_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesManager().init();
    StreakService().init();
  });

  group('TaskCategory Tests', () {
    test('TaskCategory.fromId returns correct category or fallback', () {
      final work = TaskCategory.fromId('Work');
      expect(work.nameEn, 'Work');
      expect(work.name, 'Work');

      final unknown = TaskCategory.fromId('unknown_xyz');
      expect(unknown.id, 'General');

      final nullCategory = TaskCategory.fromId(null);
      expect(nullCategory.id, 'General');
    });
  });

  group('TaskModels & Subtasks Tests', () {
    test('Subtasks progress calculation', () {
      final task = TaskModels(
        id: 1,
        taskName: 'Project Milestone',
        taskDescription: 'Execute tasks',
        isHighPriority: true,
        priority: 4,
        category: 'Work',
      );

      expect(task.subtasks.isEmpty, true);
      expect(task.subtasksProgress, 0.0);

      task.subtasks = [
        SubTaskModel(id: '1', title: 'Step 1', isDone: true),
        SubTaskModel(id: '2', title: 'Step 2', isDone: false),
        SubTaskModel(id: '3', title: 'Step 3', isDone: false),
        SubTaskModel(id: '4', title: 'Step 4', isDone: true),
      ];

      expect(task.completedSubtasksCount, 2);
      expect(task.subtasksProgress, 0.5);
    });

    test('Overdue logic accurately detects past due dates', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final overdueTask = TaskModels(
        id: 2,
        taskName: 'Overdue task',
        taskDescription: '',
        isHighPriority: false,
        dueDate: yesterday,
        isDone: false,
      );
      expect(overdueTask.isOverdue, true);

      // If marked done, should not be overdue
      overdueTask.isDone = true;
      expect(overdueTask.isOverdue, false);

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final futureTask = TaskModels(
        id: 3,
        taskName: 'Future task',
        taskDescription: '',
        isHighPriority: false,
        dueDate: tomorrow,
        isDone: false,
      );
      expect(futureTask.isOverdue, false);
    });

    test('TaskModels JSON serialization & deserialization', () {
      final original = TaskModels(
        id: 10,
        taskName: 'Complete Mobile App',
        taskDescription: 'Groq AI integration',
        isHighPriority: true,
        priority: 4,
        category: 'Work',
        dueTime: '04:00 PM',
        rawSubtasks: [
          {'id': 's1', 'title': 'Design UI', 'isDone': true},
        ],
      );

      final json = original.toJson();
      final restored = TaskModels.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.taskName, original.taskName);
      expect(restored.priority, 4);
      expect(restored.category, 'Work');
      expect(restored.subtasks.length, 1);
      expect(restored.subtasks.first.title, 'Design UI');
    });
  });

  group('StreakService Tests', () {
    test('Initial streak and levels', () {
      final service = StreakService();
      expect(service.currentStreak, 0);
      expect(service.totalXP, 0);
      expect(service.currentLevel, 1);
    });

    test('Completing task increments streak and XP', () async {
      final service = StreakService();
      await service.recordTaskCompleted();

      expect(service.currentStreak, 1);
      expect(service.bestStreak, 1);
      expect(service.totalCompleted, 1);
      expect(service.totalXP, 10);
    });
  });

  group('HabitsService & HabitItem Tests', () {
    test('HabitItem toggling and streak calculation', () {
      final habit = HabitItem(
        id: 'h1',
        title: 'Drink Water',
        iconKey: 'water',
        colorValue: 0xFF3B82F6,
      );

      expect(habit.isCompletedToday, false);
      expect(habit.currentStreak, 0);

      habit.toggleToday();
      expect(habit.isCompletedToday, true);
      expect(habit.currentStreak, 1);

      habit.toggleToday();
      expect(habit.isCompletedToday, false);
      expect(habit.currentStreak, 0);
    });

    test('HabitsService initialization, toggle and heatmap data', () async {
      final habitsService = HabitsService();
      await habitsService.init();

      expect(habitsService.habitsNotifier.value.isNotEmpty, true);
      final initialHabit = habitsService.habitsNotifier.value.first;

      await habitsService.toggleHabit(initialHabit.id);
      expect(habitsService.totalCompletedToday, 1);

      final heatmap = habitsService.getHeatmapData(7);
      expect(heatmap.length, 7);
    });
  });

  group('AIService Smart NLP Tests', () {
    test('parseNaturalLanguageTask extracts task title, priority and category', () {
      final aiService = AIService();
      final result = aiService.parseNaturalLanguageTask(
        'Finish presentation slides tomorrow high #Work',
      );

      expect(result.title, contains('Finish presentation slides'));
      expect(result.priority, 'high');
      expect(result.categoryId, 'Work');
      expect(result.dueDate, isNotNull);
    });

    test('AIService fallback daily plan generation', () {
      final aiService = AIService();
      final pendingTasks = [
        TaskModels(
          id: 1,
          taskName: 'Critical Bugfix',
          taskDescription: 'Fix crash on startup',
          isHighPriority: true,
          category: 'Work',
        ),
      ];

      final plan = aiService.generateDailyPlan(pendingTasks: pendingTasks);
      expect(plan, isA<Future<AIDailyPlan>>());
    });
  });
}
