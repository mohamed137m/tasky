import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF15B86C),
    secondary: Color(0xff3A4640),
    primaryContainer: Color(0xffFFFFFF),
    surface: Color(0xffF6F7F9),
    onSurface: Color(0xff161F1B),
    outline: Color(0xffD1DAD6),
    outlineVariant: Color(0xffE2E8F0),
  ),
  scaffoldBackgroundColor: const Color(0xffF6F7F9),
  dividerColor: const Color(0xffE2E8F0),
  dividerTheme: const DividerThemeData(
    color: Color(0xffE2E8F0),
    thickness: 1,
    space: 1,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xffD1DAD6), width: 0.8),
    ),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0xff161F1B)),
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xffFFFFFF),
    disabledColor: const Color(0xffF1F5F9),
    selectedColor: const Color(0xFF15B86C),
    secondarySelectedColor: const Color(0xFF15B86C),
    labelStyle: const TextStyle(color: Color(0xff3A4640), fontSize: 12),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
    brightness: Brightness.light,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: Color(0xffD1DAD6)),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF15B86C),
    linearTrackColor: Color(0xffE2E8F0),
    circularTrackColor: Color(0xffE2E8F0),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    modalBackgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
  tabBarTheme: TabBarThemeData(
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: Colors.transparent,
    labelColor: Colors.white,
    unselectedLabelColor: const Color(0xff5A6862),
    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
    indicator: BoxDecoration(
      color: const Color(0xFF15B86C),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    headerBackgroundColor: const Color(0xFF15B86C),
    headerForegroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.white,
    hourMinuteColor: const Color(0xffF1F5F9),
    hourMinuteTextColor: const Color(0xff161F1B),
    dialBackgroundColor: const Color(0xffF1F5F9),
    dialHandColor: const Color(0xFF15B86C),
    dialTextColor: const Color(0xff161F1B),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  switchTheme: SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF15B86C);
      }
      return const Color(0xffE2E8F0);
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
      foregroundColor: const Color(0xff3A4640),
      side: const BorderSide(color: Color(0xffD1DAD6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
    labelSmall: TextStyle(color: Color(0xff8A9791), fontSize: 13),
    labelMedium: TextStyle(
      color: Color(0xff5A6862),
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    displayMedium: TextStyle(
      color: Color(0xff8A9791),
      fontSize: 15,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.lineThrough,
      decorationColor: Color(0xff8A9791),
    ),
    titleSmall: TextStyle(
      color: Color(0xff5A6862),
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 19,
      fontWeight: FontWeight.bold,
    ),
    displayLarge: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: const Color(0xFFFFFFFF),
    filled: true,
    hintStyle: const TextStyle(color: Color(0xff8A9791), fontSize: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xffD1DAD6), width: 1),
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
      borderSide: const BorderSide(color: Color(0xffD1DAD6), width: 1),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    side: const BorderSide(color: Color(0xffCBD5E1), width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF15B86C);
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(Colors.white),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF161F1B)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xffFFFFFF),
    unselectedItemColor: Color(0xff64748B),
    unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    selectedItemColor: Color(0xff15B86C),
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  ),
  listTileTheme: const ListTileThemeData(
    titleTextStyle: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
  ),
  splashFactory: NoSplash.splashFactory,
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xffFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xffE2E8F0), width: 0.8),
    ),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(color: Color(0xff161F1B), fontWeight: FontWeight.w500),
    ),
    elevation: 8,
  ),
  dialogTheme: DialogThemeData(
    titleTextStyle: const TextStyle(color: Color(0xff161F1B), fontSize: 18, fontWeight: FontWeight.bold),
    contentTextStyle: const TextStyle(color: Color(0xff3A4640), fontSize: 14),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
);
