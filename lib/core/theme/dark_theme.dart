import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    secondary: Color(0xffC6C6C6),
    primaryContainer: Color(0xff282828),
  ),
  scaffoldBackgroundColor: Color(0xff181818),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Color(0xffFFFCFC),
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
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Color(0xFFFFFCFC)),
    ),
  ),
  textTheme: TextTheme(
    displaySmall: TextStyle(
      color: Color(0xffFFFFFF),
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(color: Color(0xff6D6D6D), fontSize: 14),
    labelMedium: TextStyle(
      color: Color(0xffC6C6C6),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    //isDone Tasks
    displayMedium: TextStyle(
      color: Color(0xffA0A0A0),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.lineThrough,
      decorationColor: Color(0xffA0A0A0),
    ),
    titleSmall: TextStyle(
      color: Color(0xffC6C6C6),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(
      color: Color(0xffFFFCFC),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      color: Color(0xffFFFCFC),
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ),
    displayLarge: TextStyle(
      color: Color(0xffFFFCFC),
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red),
    ),
    fillColor: Color(0xff282828),
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(color: Color(0xff6E6E6E), width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(3),
    ),
  ),
  iconTheme: IconThemeData(color: Color(0xFFFFFCFC)),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xff181818),
    unselectedItemColor: Color(0xffC6C6C6),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    selectedItemColor: Color(0xff15B86C),
  ),

  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(
      color: Color(0xffFFFCFC),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
  ),
  splashFactory: NoSplash.splashFactory,

  popupMenuTheme: PopupMenuThemeData(
    color: Color(0xff181818),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(16),
      side: BorderSide(color: Color(0xff15B86C), width: 1),
    ),
    labelTextStyle: WidgetStateProperty.all(
      TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
    ),
    elevation: 5,
    shadowColor: Color(0xff15B86C),
  ),
  dialogTheme: DialogThemeData(
    titleTextStyle: TextStyle(color: Colors.white),
    contentTextStyle: TextStyle(color: Colors.white),
    backgroundColor: Color(0xff181818),
  ),
  
);
