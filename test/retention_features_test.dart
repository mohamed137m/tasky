import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/services/activity_rings_service.dart';
import 'package:tasky/core/services/garden_service.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/services/templates_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesManager().init();
    await ActivityRingsService().init();
    await GardenService().init();
  });

  group('ActivityRingsService Tests', () {
    test('ActivityRingsData calculates progress and closed rings correctly', () {
      const data = ActivityRingsData(
        tasksCompleted: 5,
        tasksGoal: 5,
        habitsCompleted: 3,
        habitsGoal: 3,
        focusMinutes: 50,
        focusMinutesGoal: 50,
      );

      expect(data.tasksProgress, 1.0);
      expect(data.habitsProgress, 1.0);
      expect(data.focusProgress, 1.0);
      expect(data.isAllRingsClosed, true);
    });

    test('addFocusMinutes increases focus minutes for today', () async {
      await ActivityRingsService().addFocusMinutes(25);
      final val = ActivityRingsService.ringsNotifier.value;
      expect(val.focusMinutes >= 25, true);
    });
  });

  group('GardenService Tests', () {
    test('GardenService initializes and earns drops correctly', () async {
      final initialDrops = GardenService().waterDropsNotifier.value;
      await GardenService().addWaterDrops(20);
      expect(GardenService().waterDropsNotifier.value, initialDrops + 20);
    });

    test('GardenService can water tree and progress tree growth', () async {
      await GardenService().addWaterDrops(50);
      final trees = GardenService().treesNotifier.value;
      expect(trees.isNotEmpty, true);

      final firstTree = trees.first;
      final initialWater = firstTree.currentWater;
      final success = await GardenService().waterTree(firstTree.id, 15);

      expect(success, true);
      expect(firstTree.currentWater, initialWater + 15);
    });

    test('GardenService unlocks badges', () async {
      await GardenService().unlockBadge('early_bird');
      final badges = GardenService().badgesNotifier.value;
      final earlyBird = badges.firstWhere((b) => b.id == 'early_bird');
      expect(earlyBird.isUnlocked, true);
    });
  });

  group('TemplatesService Tests', () {
    test('Presets list is not empty and has valid task bundles', () {
      expect(TemplatesService.presets.isNotEmpty, true);
      final morning = TemplatesService.presets
          .firstWhere((p) => p.id == 'morning_routine');
      expect(morning.taskTitles.length, 4);
      expect(morning.icon, '🌅');
    });
  });
}
