import 'package:flutter/material.dart';
import 'package:tasky/core/services/activity_rings_service.dart';
import 'package:tasky/core/services/garden_service.dart';
import 'package:tasky/core/services/streak_service.dart';
import 'package:tasky/core/theme/theme_controller.dart';

class DailyReflectionDialog extends StatefulWidget {
  const DailyReflectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const DailyReflectionDialog(),
    );
  }

  @override
  State<DailyReflectionDialog> createState() => _DailyReflectionDialogState();
}

class _DailyReflectionDialogState extends State<DailyReflectionDialog> {
  int _selectedRating = 4;
  final TextEditingController _noteController = TextEditingController();

  final List<String> _moodEmojis = ['😞', '😐', '🙂', '😄', '🚀'];
  final List<String> _moodLabels = ['Rough', 'Okay', 'Good', 'Great', 'Unstoppable'];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark();
    final theme = Theme.of(context);
    final ringsData = ActivityRingsService.ringsNotifier.value;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🌙', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 12),
              Text(
                'Daily Evening Reflection',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'How do you feel about your productivity today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),

              // Mood Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final isSelected = _selectedRating == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedRating = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(_moodEmojis[index], style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 4),
                          Text(
                            _moodLabels[index],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF8B5CF6) : theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Stats summary pills
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatPill('✅ Tasks', '${ringsData.tasksCompleted} Done', theme),
                    _buildStatPill('🎯 Habits', '${ringsData.habitsCompleted} Kept', theme),
                    _buildStatPill('⏱️ Focus', '${ringsData.focusMinutes}m', theme),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Optional Reflection Note
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'One win or lesson from today (optional)...',
                  hintStyle: TextStyle(fontSize: 12, color: theme.colorScheme.secondary),
                  filled: true,
                  fillColor: isDark ? theme.colorScheme.surface : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await GardenService().addWaterDrops(15);
                    await StreakService().recordTaskCompleted();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Day logged! Earned +15 Water Drops for your Garden!'),
                          backgroundColor: Color(0xFF15B86C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15B86C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Complete Reflection (+15 💧)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
