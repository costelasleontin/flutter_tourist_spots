import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TouristSpotsTheme extends ChangeNotifier {
  //Android and Web Theme Section
  bool _darkMode = false;

  static ThemeData light() {
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white)),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.black,
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.black)),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.black,
      ),
      drawerTheme: const DrawerThemeData(scrimColor: Colors.black),
      textTheme: const TextTheme(
        titleMedium: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  bool get getMode => _darkMode;

  void toggleTheme(bool toggleValue) {
    _darkMode = toggleValue;
    notifyListeners();
  }

  //IOS Theme Section
  static CupertinoThemeData cupertinoTheme(Brightness brightness) {
    return CupertinoThemeData(
      brightness: brightness,
      barBackgroundColor: const CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.white,
        darkColor: CupertinoColors.black,
      ),
      primaryColor: const CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.activeBlue,
        darkColor: CupertinoColors.activeBlue,
      ),
      textTheme: const CupertinoTextThemeData(
        textStyle: TextStyle(
          color: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.black, darkColor: CupertinoColors.white),
        ),
        primaryColor: CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black, darkColor: CupertinoColors.white),
      ),
    );
  }
}
