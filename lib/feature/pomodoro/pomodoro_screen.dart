import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/services/activity_rings_service.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/core/services/garden_service.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/core/services/streak_service.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';

enum PomodoroMode {
  focus(title: 'Focus', durationMinutes: 25, color: Color(0xFF15B86C)),
  shortBreak(title: 'Short Break', durationMinutes: 5, color: Color(0xFF3B82F6)),
  longBreak(title: 'Long Break', durationMinutes: 15, color: Color(0xFF8B5CF6));

  final String title;
  final int durationMinutes;
  final Color color;

  const PomodoroMode({
    required this.title,
    required this.durationMinutes,
    required this.color,
  });
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  PomodoroMode _currentMode = PomodoroMode.focus;
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  int _completedSessions = 0;
  TaskModels? _selectedTask;
  List<TaskModels> _availableTasks = [];
  String _activeSoundscape = 'Off';
  String _activeSoundscapeIcon = '🔇';

  @override
  void initState() {
    super.initState();
    _loadAvailableTasks();
    _setMode(PomodoroMode.focus);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadAvailableTasks() {
    final tasks = HiveStorageManger().loadTasks();
    setState(() {
      _availableTasks = tasks.where((t) => !t.isDone).toList();
      if (_availableTasks.isNotEmpty) {
        _selectedTask = _availableTasks.first;
      }
    });
  }

  void _setMode(PomodoroMode mode) {
    _timer?.cancel();
    setState(() {
      _currentMode = mode;
      _isRunning = false;
      _totalSeconds = mode.durationMinutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    HapticFeedback.lightImpact();
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    HapticFeedback.heavyImpact();

    if (_currentMode == PomodoroMode.focus) {
      setState(() {
        _completedSessions++;
      });
      NotificationService().showPomodoroNotification(isBreak: false);
      // Award extra XP & Water Drops for focus session!
      await StreakService().recordTaskCompleted();
      await ActivityRingsService().addFocusMinutes(25);
      await GardenService().addWaterDrops(25);
      await GardenService().unlockBadge('deep_focus');
      AdService().showInterstitialIfReady();

      if (mounted) {
        _showCompletionDialog();
      }
    } else {
      setState(() {
        _isRunning = false;
      });
      NotificationService().showPomodoroNotification(isBreak: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Break finished! Ready to focus again? ⚡'),
            backgroundColor: Color(0xFF15B86C),
          ),
        );
        _setMode(PomodoroMode.focus);
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🎉 Great Job!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You finished a 25-minute focus session! (+15 XP earned 🔥)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_selectedTask != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15B86C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Task: "${_selectedTask!.taskName}"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Would you like to mark this task as completed?'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _setMode(PomodoroMode.shortBreak);
              },
              child: const Text('Take a Short Break'),
            ),
            if (_selectedTask != null)
              ElevatedButton(
                onPressed: () async {
                  final tasks = HiveStorageManger().loadTasks();
                  final idx =
                      tasks.indexWhere((e) => e.id == _selectedTask!.id);
                  if (idx != -1) {
                    tasks[idx].isDone = true;
                    tasks[idx].completedAt = DateTime.now();
                    await HiveStorageManger().saveTasks(tasks);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadAvailableTasks();
                    _setMode(PomodoroMode.shortBreak);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15B86C),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mark Done & Rest'),
              ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _totalSeconds == 0
        ? 0.0
        : (_totalSeconds - _remainingSeconds) / _totalSeconds;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Focus Timer (Pomodoro)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: Text(_activeSoundscapeIcon, style: const TextStyle(fontSize: 18)),
            tooltip: 'Ambient Soundscapes: $_activeSoundscape',
            onPressed: _showSoundscapesSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Tasks',
            onPressed: _loadAvailableTasks,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mode Selector Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: PomodoroMode.values.map((mode) {
                    final isSelected = _currentMode == mode;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _setMode(mode),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? mode.color
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: mode.color.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              mode.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? const Color(0xffB0B0B0) : const Color(0xff5A6862)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Linked Task Selector
              if (_availableTasks.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.track_changes_rounded,
                        color: Color(0xFF15B86C),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Focusing on: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<TaskModels>(
                            value: _selectedTask,
                            isExpanded: true,
                            hint: const Text('Select a task'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _availableTasks.map((t) {
                              return DropdownMenuItem<TaskModels>(
                                value: t,
                                child: Text(
                                  t.taskName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedTask = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Circular Countdown Timer
              Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Track
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 12,
                          valueColor: AlwaysStoppedAnimation(
                            isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      // Active Progress Track
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation(_currentMode.color),
                        ),
                      ),
                      // Time Display & Status
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _currentMode.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isRunning ? 'FOCUSING' : 'READY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _currentMode.color,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Control Buttons (Reset, Play/Pause, Skip)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filledTonal(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.replay_rounded),
                    iconSize: 26,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Main Start/Pause Button
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _currentMode.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _currentMode.color.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Skip to next mode
                  IconButton.filledTonal(
                    onPressed: () {
                      if (_currentMode == PomodoroMode.focus) {
                        _setMode(PomodoroMode.shortBreak);
                      } else {
                        _setMode(PomodoroMode.focus);
                      }
                    },
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 26,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Today's Focus Stats
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '🍅 $_completedSessions',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sessions Today',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Column(
                      children: [
                        Text(
                          '⚡ ${_completedSessions * 25}m',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15B86C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Focused Time',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Column(
                      children: [
                        Text(
                          '🔥 +${_completedSessions * 15}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'XP Earned',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // AdMob Banner Ad
              const Center(
                child: TaskyBannerAdWidget(
                  margin: EdgeInsets.symmetric(vertical: 4),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoundscapesSheet() {
    final sounds = [
      {'name': 'Off', 'icon': '🔇', 'desc': 'Silence'},
      {'name': 'Gentle Rain', 'icon': '🌧️', 'desc': 'Soothing rain drops'},
      {'name': 'Cafe Vibes', 'icon': '☕', 'desc': 'Ambient background murmur'},
      {'name': 'Ocean Waves', 'icon': '🌊', 'desc': 'Rhythmic calming tide'},
      {'name': 'Forest Birds', 'icon': '🌲', 'desc': 'Peaceful woodland nature'},
      {'name': 'Campfire', 'icon': '🔥', 'desc': 'Crackling fire embers'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ambient Focus Soundscapes 🎧',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Background audio atmosphere for zero-distraction deep work',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              ...sounds.map((s) {
                final isSelected = _activeSoundscape == s['name'];
                return ListTile(
                  leading: Text(s['icon']!, style: const TextStyle(fontSize: 24)),
                  title: Text(s['name']!, style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF15B86C) : null,
                  )),
                  subtitle: Text(s['desc']!),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF15B86C))
                      : null,
                  onTap: () {
                    setState(() {
                      _activeSoundscape = s['name']!;
                      _activeSoundscapeIcon = s['icon']!;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Soundscape set to: ${s['name']} ${s['icon']}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
