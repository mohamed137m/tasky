import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF15B86C),
    secondary: Color(0xffC6C6C6),
    primaryContainer: Color(0xff252525),
    surface: Color(0xff181818),
    onSurface: Color(0xffF5F5F5),
    outline: Color(0xff383838),
    outlineVariant: Color(0xff2A2A2A),
  ),
  scaffoldBackgroundColor: const Color(0xff141414),
  dividerColor: const Color(0xff2E2E2E),
  dividerTheme: const DividerThemeData(
    color: Color(0xff2E2E2E),
    thickness: 1,
    space: 1,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xff252525),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xff383838), width: 0.8),
    ),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0xffFFFFFF)),
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Color(0xffFFFCFC),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xff252525),
    disabledColor: const Color(0xff181818),
    selectedColor: const Color(0xFF15B86C),
    secondarySelectedColor: const Color(0xFF15B86C),
    labelStyle: const TextStyle(color: Color(0xffB0B0B0), fontSize: 12),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
    brightness: Brightness.dark,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: Color(0xff383838)),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF15B86C),
    linearTrackColor: Color(0xff2A2A2A),
    circularTrackColor: Color(0xff2A2A2A),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xff1E1E1E),
    modalBackgroundColor: Color(0xff1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
  tabBarTheme: TabBarThemeData(
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: Colors.transparent,
    labelColor: Colors.white,
    unselectedLabelColor: const Color(0xffB0B0B0),
    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
    indicator: BoxDecoration(
      color: const Color(0xFF15B86C),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: const Color(0xff222222),
    headerBackgroundColor: const Color(0xFF15B86C),
    headerForegroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: const Color(0xff222222),
    hourMinuteColor: const Color(0xff2A2A2A),
    hourMinuteTextColor: Colors.white,
    dialBackgroundColor: const Color(0xff2A2A2A),
    dialHandColor: const Color(0xFF15B86C),
    dialTextColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  switchTheme: SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF15B86C);
      }
      return const Color(0xff3A3A3A);
    }),
    thumbColor: WidgetStateProperty.all(Colors.white),
    trackOutlineWidth: WidgetStateProperty.all(0),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF15B86C),
      foregroundColor: const Color(0xFFFFFCFC),
      fixedSize: const Size(double.infinity, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFF15B86C)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xffC6C6C6),
      side: const BorderSide(color: Color(0xff3A3A3A)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      color: Color(0xffFFFFFF),
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
    labelSmall: TextStyle(color: Color(0xff888888), fontSize: 13),
    labelMedium: TextStyle(
      color: Color(0xffB0B0B0),
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    displayMedium: TextStyle(
      color: Color(0xff757575),
      fontSize: 15,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.lineThrough,
      decorationColor: Color(0xff757575),
    ),
    titleSmall: TextStyle(
      color: Color(0xffA8A8A8),
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(
      color: Color(0xffF5F5F5),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Color(0xffFFFFFF),
      fontSize: 19,
      fontWeight: FontWeight.bold,
    ),
    displayLarge: TextStyle(
      color: Color(0xffFFFFFF),
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: const Color(0xff252525),
    filled: true,
    hintStyle: const TextStyle(color: Color(0xff757575), fontSize: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xff383838), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF15B86C), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xff383838), width: 1),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    side: const BorderSide(color: Color(0xff555555), width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF15B86C);
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(Colors.white),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFE5E5E5)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xff181818),
    unselectedItemColor: Color(0xff8E8E93),
    unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    selectedItemColor: Color(0xff15B86C),
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  ),
  listTileTheme: const ListTileThemeData(
    titleTextStyle: TextStyle(
      color: Color(0xffF0F0F0),
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
  ),
  splashFactory: NoSplash.splashFactory,
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xff242424),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xff3A3A3A), width: 0.8),
    ),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
    elevation: 8,
  ),
  dialogTheme: DialogThemeData(
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    contentTextStyle: const TextStyle(color: Color(0xffC6C6C6), fontSize: 14),
    backgroundColor: const Color(0xff222222),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
);
