import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    secondary: Color(0xff3A4640),
    primaryContainer: Color(0xffFFFFFF),
  ),
  scaffoldBackgroundColor: Color(0xffF6F7F9),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ),
  ),

  switchTheme: SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Color(0xFF15B86C);
      }
      return Colors.white;
    }),
    trackOutlineWidth: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return 0;
      }
      return 2;
    }),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Color(0xFF15B86C)),
      foregroundColor: WidgetStateProperty.all(Color(0xFFFFFCFC)),
      fixedSize: WidgetStateProperty.all(Size(double.infinity, 42)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.black)),
  ),
  textTheme: TextTheme(
    displaySmall: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(color: Color(0xff9E9E9E), fontSize: 14),
    labelMedium: TextStyle(
      color: Color(0xff3A4640),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    titleSmall: TextStyle(
      color: Color(0xff3A4640),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ),
    displayLarge: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),

    //isDone Tasks
    displayMedium: TextStyle(
      color: Color(0xff6A6A6A),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.lineThrough,
      decorationColor: Color(0xff6A6A6A),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xffD1DAD6), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xffD1DAD6), width: 1),
    ),
    fillColor: Color(0xFFFFFFFF),
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xffD1DAD6), width: 1),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(color: Color(0xffD1DAD6), width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(3),
    ),
  ),

  iconTheme: IconThemeData(color: Color(0xFF161F1B)),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xffF6F7F9),
    unselectedItemColor: Color(0xff3A4640),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    selectedItemColor: Color(0xff15B86C),
  ),

  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(
      color: Color(0xff161F1B),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
  ),
  splashFactory: NoSplash.splashFactory,
  popupMenuTheme: PopupMenuThemeData(
    color: Color(0xffF6F7F9),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(16),
      side: BorderSide(color: Color(0xff15B86C), width: 1),
    ),
    labelTextStyle: WidgetStateProperty.all(
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
    ),
    elevation: 5,
    shadowColor: Color(0xff15B86C),
  ),
  dialogTheme: DialogThemeData(backgroundColor: Color(0xffF6F7F9)),
);
