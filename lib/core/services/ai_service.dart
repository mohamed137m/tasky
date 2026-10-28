import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tasky/Models/task_models.dart';

class AIScheduleBlock {
  final String timeRange;
  final String title;
  final String rationale;
  final List<String> taskNames;

  const AIScheduleBlock({
    required this.timeRange,
    required this.title,
    required this.rationale,
    required this.taskNames,
  });

  factory AIScheduleBlock.fromMap(Map<String, dynamic> map) {
    return AIScheduleBlock(
      timeRange: map['timeRange'] as String? ?? 'Upcoming Block',
      title: map['title'] as String? ?? 'Focus Session',
      rationale: map['rationale'] as String? ?? 'Prioritize high value output',
      taskNames: (map['taskNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class AIDailyPlan {
  final String dailyMission;
  final List<AIScheduleBlock> scheduleBlocks;
  final String productivityTip;
  final String motivationQuote;

  const AIDailyPlan({
    required this.dailyMission,
    required this.scheduleBlocks,
    required this.productivityTip,
    required this.motivationQuote,
  });

  factory AIDailyPlan.fromMap(Map<String, dynamic> map) {
    final blocksList = (map['scheduleBlocks'] as List<dynamic>?)
            ?.map((e) => AIScheduleBlock.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AIDailyPlan(
      dailyMission: map['dailyMission'] as String? ??
          'Focus on your highest leverage tasks today to build unstoppable momentum.',
      scheduleBlocks: blocksList,
      productivityTip: map['productivityTip'] as String? ??
          'Work in 25-minute Pomodoro bursts followed by 5-minute mental breaks.',
      motivationQuote: map['motivationQuote'] as String? ??
          'Action is the foundational key to all success.',
    );
  }
}

class SmartTaskParseResult {
  final String title;
  final DateTime? dueDate;
  final String priority; // 'high', 'medium', 'low'
  final String? categoryId;

  const SmartTaskParseResult({
    required this.title,
    this.dueDate,
    this.priority = 'low',
    this.categoryId,
  });
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Groq API Key (configure via --dart-define=GROQ_API_KEY=your_key)
  static const String _apiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-120b';

  /// Breaks down a task into actionable subtasks.
  Future<List<String>> generateSubtasks(
    String taskName, {
    String? taskDescription,
  }) async {
    if (_apiKey.isEmpty) {
      return _fallbackSubtasks(taskName);
    }

    try {
      final prompt = '''
You are an expert productivity assistant.
The user wants to accomplish this task:
Task: "$taskName"
${taskDescription != null && taskDescription.isNotEmpty ? 'Details: "$taskDescription"' : ''}

Break this task down into 3 to 5 clear, concise, actionable subtasks in English.
Return ONLY a valid JSON array of strings without markdown formatting, code blocks, or extra text.
Example format:
["First step", "Second step", "Third step"]
''';

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are an assistant that outputs strictly valid JSON arrays of strings in English.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.4,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            data['choices']?[0]?['message']?['content'] as String? ?? '';
        final cleanContent = _extractJson(content, isArray: true);
        final dynamic parsed = jsonDecode(cleanContent);
        if (parsed is List) {
          return parsed.map((e) => e.toString().trim()).toList();
        }
      }
    } catch (_) {
      // In case of network error or parsing failure, return fallback suggestions
    }

    return _fallbackSubtasks(taskName);
  }

  /// Generates a personalized daily roadmap and schedule briefing using AI.
  Future<AIDailyPlan> generateDailyPlan({
    required List<TaskModels> pendingTasks,
    String? userName,
  }) async {
    if (_apiKey.isEmpty) {
      return _fallbackDailyPlan(pendingTasks);
    }

    final taskSummaries = pendingTasks.map((t) {
      return '- "${t.taskTitle}" (Priority: ${t.highPriority ? 'High' : 'Normal'}, Category: ${t.category})';
    }).join('\n');

    try {
      final prompt = '''
You are a world-class productivity coach for ${userName ?? 'Explorer'}.
Here are the user's active pending tasks:
$taskSummaries

Create a high-impact daily schedule plan in English.
Return ONLY a valid JSON object in this exact schema with NO surrounding markdown or backticks:
{
  "dailyMission": "A concise, motivating 1-sentence focus objective for today",
  "scheduleBlocks": [
    {
      "timeRange": "09:00 AM - 11:30 AM",
      "title": "Deep Focus Work",
      "rationale": "High cognitive energy period",
      "taskNames": ["Task name 1"]
    },
    {
      "timeRange": "01:00 PM - 03:00 PM",
      "title": "Execution & Operations",
      "rationale": "Steady progress on primary goals",
      "taskNames": ["Task name 2"]
    },
    {
      "timeRange": "04:30 PM - 05:30 PM",
      "title": "Daily Wrap-up & Review",
      "rationale": "Clear backlog and plan tomorrow",
      "taskNames": ["Review subtasks"]
    }
  ],
  "productivityTip": "A practical 1-sentence tip tailored to their workload",
  "motivationQuote": "A concise inspiring quote"
}
''';

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are an AI productivity coach. Output only valid JSON.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.5,
              'max_tokens': 800,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            data['choices']?[0]?['message']?['content'] as String? ?? '';
        final cleanContent = _extractJson(content, isArray: false);
        final dynamic parsed = jsonDecode(cleanContent);
        if (parsed is Map<String, dynamic>) {
          return AIDailyPlan.fromMap(parsed);
        }
      }
    } catch (_) {}

    // Algorithmic Fallback
    return _fallbackDailyPlan(pendingTasks);
  }

  /// Parses natural language task strings into structured task components
  SmartTaskParseResult parseNaturalLanguageTask(String raw) {
    String text = raw.trim();
    String priority = 'low';
    String? category;
    DateTime? dueDate;

    // Detect Priority
    final lower = text.toLowerCase();
    if (lower.contains('urgent') ||
        lower.contains('p1') ||
        lower.contains('high priority') ||
        lower.contains('high')) {
      priority = 'high';
      text = text.replaceAll(RegExp(r'\b(urgent|p1|high priority|high)\b', caseSensitive: false), '');
    } else if (lower.contains('medium') || lower.contains('p2')) {
      priority = 'medium';
      text = text.replaceAll(RegExp(r'\b(medium|p2)\b', caseSensitive: false), '');
    }

    // Detect Category tags (e.g. #Work, #Study, #Personal, #Health, #Finance)
    final tagMatch = RegExp(r'#(\w+)').firstMatch(text);
    if (tagMatch != null) {
      final tag = tagMatch.group(1)!;
      final matchedCategory = _matchCategory(tag);
      if (matchedCategory != null) {
        category = matchedCategory;
      }
      text = text.replaceAll(tagMatch.group(0)!, '');
    }

    // Detect Relative Dates
    final now = DateTime.now();
    if (lower.contains('today')) {
      dueDate = DateTime(now.year, now.month, now.day, 18, 0);
      text = text.replaceAll(RegExp(r'\btoday\b', caseSensitive: false), '');
    } else if (lower.contains('tomorrow')) {
      final tomorrow = now.add(const Duration(days: 1));
      dueDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0);
      text = text.replaceAll(RegExp(r'\btomorrow\b', caseSensitive: false), '');
    } else if (lower.contains('next week')) {
      final nextWeek = now.add(const Duration(days: 7));
      dueDate = DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 9, 0);
      text = text.replaceAll(RegExp(r'\bnext week\b', caseSensitive: false), '');
    }

    // Clean extra whitespace
    final cleanTitle = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return SmartTaskParseResult(
      title: cleanTitle.isEmpty ? raw : cleanTitle,
      dueDate: dueDate,
      priority: priority,
      categoryId: category,
    );
  }

  String? _matchCategory(String tag) {
    final lower = tag.toLowerCase();
    if (lower.contains('work')) return 'Work';
    if (lower.contains('pers') || lower.contains('life')) return 'Personal';
    if (lower.contains('stud') || lower.contains('book')) return 'Study';
    if (lower.contains('fit') || lower.contains('gym') || lower.contains('health')) {
      return 'Health';
    }
    if (lower.contains('money') || lower.contains('fin')) return 'Finance';
    return null;
  }

  String _extractJson(String raw, {required bool isArray}) {
    String text = raw.trim();
    final openChar = isArray ? '[' : '{';
    final closeChar = isArray ? ']' : '}';

    final first = text.indexOf(openChar);
    final last = text.lastIndexOf(closeChar);
    if (first != -1 && last != -1 && last > first) {
      return text.substring(first, last + 1);
    }
    return text;
  }

  List<String> _fallbackSubtasks(String taskName) {
    return [
      'Define requirements and prepare tools',
      'Execute the core part of the task',
      'Review and verify completion',
    ];
  }

  AIDailyPlan _fallbackDailyPlan(List<TaskModels> pendingTasks) {
    final highPriority = pendingTasks.where((t) => t.highPriority).toList();
    final regular = pendingTasks.where((t) => !t.highPriority).toList();

    final blocks = <AIScheduleBlock>[
      AIScheduleBlock(
        timeRange: '09:00 AM - 11:30 AM',
        title: 'Morning Deep Work',
        rationale: 'High cognitive bandwidth window for top priorities',
        taskNames: highPriority.isNotEmpty
            ? highPriority.take(2).map((t) => t.taskTitle).toList()
            : ['Deep focus session on top goals'],
      ),
      AIScheduleBlock(
        timeRange: '01:00 PM - 03:30 PM',
        title: 'Afternoon Execution',
        rationale: 'Drive continuous progress on key project milestones',
        taskNames: regular.isNotEmpty
            ? regular.take(2).map((t) => t.taskTitle).toList()
            : ['Execute operational tasks & check subtasks'],
      ),
      AIScheduleBlock(
        timeRange: '04:30 PM - 05:30 PM',
        title: 'Wrap-up & Organization',
        rationale: 'Review today’s outcomes and set tomorrow up for success',
        taskNames: ['Review completed tasks & mark achievements'],
      ),
    ];

    return AIDailyPlan(
      dailyMission: highPriority.isNotEmpty
          ? 'Conquer ${highPriority.first.taskTitle} first to unlock peak momentum for your day.'
          : 'Complete your core tasks in steady focus intervals to maintain your daily streak.',
      scheduleBlocks: blocks,
      productivityTip:
          'Break large tasks into 15-minute sprints using the Pomodoro timer.',
      motivationQuote:
          'Small daily improvements over time lead to stunning results.',
    );
  }
}
