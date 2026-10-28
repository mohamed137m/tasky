import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/services/activity_rings_service.dart';
import 'package:tasky/core/services/garden_service.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/theme/dark_theme.dart';
import 'package:tasky/core/theme/light_theme.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/feature/home/components/activity_rings_card.dart';
import 'package:tasky/feature/home/components/share_streak_modal.dart';
import 'package:tasky/feature/reflection/daily_reflection_dialog.dart';
import 'package:tasky/feature/templates/templates_sheet.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesManager().init();
    await ActivityRingsService().init();
    await GardenService().init();
  });

  group('Theme System Tests', () {
    test('Dark Theme has correct Brightness and ColorScheme tokens', () {
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.primary, const Color(0xFF15B86C));
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xff141414));
      expect(darkTheme.colorScheme.primaryContainer, const Color(0xff252525));
      expect(darkTheme.colorScheme.outline, const Color(0xff383838));

      // Component themes exist
      expect(darkTheme.chipTheme.backgroundColor, const Color(0xff252525));
      expect(darkTheme.dividerTheme.color, const Color(0xff2E2E2E));
      expect(darkTheme.progressIndicatorTheme.color, const Color(0xFF15B86C));
      expect(darkTheme.bottomSheetTheme.backgroundColor, const Color(0xff1E1E1E));
      expect(darkTheme.tabBarTheme.indicatorSize, TabBarIndicatorSize.tab);
      expect(darkTheme.datePickerTheme.backgroundColor, const Color(0xff222222));
    });

    test('Light Theme has correct Brightness and ColorScheme tokens', () {
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.primary, const Color(0xFF15B86C));
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xffF6F7F9));
      expect(lightTheme.colorScheme.primaryContainer, const Color(0xffFFFFFF));
      expect(lightTheme.colorScheme.outline, const Color(0xffD1DAD6));

      // Component themes exist
      expect(lightTheme.chipTheme.backgroundColor, const Color(0xffFFFFFF));
      expect(lightTheme.dividerTheme.color, const Color(0xffE2E8F0));
      expect(lightTheme.progressIndicatorTheme.color, const Color(0xFF15B86C));
      expect(lightTheme.bottomSheetTheme.backgroundColor, Colors.white);
      expect(lightTheme.tabBarTheme.indicatorSize, TabBarIndicatorSize.tab);
      expect(lightTheme.datePickerTheme.backgroundColor, Colors.white);
    });

    test('ThemeController toggles between Light and Dark mode', () async {
      ThemeController.themeNotifier.value = ThemeMode.dark;
      expect(ThemeController.isDark(), true);

      await ThemeController().toggle();
      expect(ThemeController.isDark(), false);
      expect(ThemeController.themeNotifier.value, ThemeMode.light);

      await ThemeController().toggle();
      expect(ThemeController.isDark(), true);
      expect(ThemeController.themeNotifier.value, ThemeMode.dark);
    });

    testWidgets('Renders Scaffold and components properly in Dark Theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            appBar: AppBar(title: const Text('Dark Mode Test')),
            body: Center(
              child: Column(
                children: [
                  const Text('Dark Mode Text'),
                  ElevatedButton(onPressed: () {}, child: const Text('Button')),
                  const Divider(),
                  FilterChip(label: const Text('Chip'), onSelected: (_) {}),
                  const CircularProgressIndicator(value: 0.5),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dark Mode Test'), findsOneWidget);
      expect(find.text('Dark Mode Text'), findsOneWidget);
    });

    testWidgets('Renders Scaffold and components properly in Light Theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: Scaffold(
            appBar: AppBar(title: const Text('Light Mode Test')),
            body: Center(
              child: Column(
                children: [
                  const Text('Light Mode Text'),
                  ElevatedButton(onPressed: () {}, child: const Text('Button')),
                  const Divider(),
                  FilterChip(label: const Text('Chip'), onSelected: (_) {}),
                  const CircularProgressIndicator(value: 0.5),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Light Mode Test'), findsOneWidget);
      expect(find.text('Light Mode Text'), findsOneWidget);
    });

    testWidgets('ActivityRingsCard renders properly in Dark and Light themes', (WidgetTester tester) async {
      // Dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: ActivityRingsCard()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Daily Activity Rings'), findsOneWidget);

      // Light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: const Scaffold(body: ActivityRingsCard()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Daily Activity Rings'), findsOneWidget);
    });

    testWidgets('TemplatesSheet renders properly in Dark and Light themes', (WidgetTester tester) async {
      // Dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: TemplatesSheet()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1-Click Productivity Templates'), findsOneWidget);

      // Light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: const Scaffold(body: TemplatesSheet()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1-Click Productivity Templates'), findsOneWidget);
    });

    testWidgets('DailyReflectionDialog renders properly in Dark and Light themes', (WidgetTester tester) async {
      // Dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: DailyReflectionDialog()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Daily Evening Reflection'), findsOneWidget);

      // Light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: const Scaffold(body: DailyReflectionDialog()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Daily Evening Reflection'), findsOneWidget);
    });

    testWidgets('ShareStreakModal renders properly in Dark and Light themes', (WidgetTester tester) async {
      // Dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: ShareStreakModal(userName: 'Alex')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TASKY PRODUCTIVITY'), findsOneWidget);

      // Light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: const Scaffold(body: ShareStreakModal(userName: 'Alex')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TASKY PRODUCTIVITY'), findsOneWidget);
    });
  });
}

