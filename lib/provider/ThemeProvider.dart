// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   bool _isDark = false;
//   bool get isDark => _isDark;
//   ThemeMode _themeMode = ThemeMode.light;
//   ThemeMode get themeMode => _themeMode;
//   late SharedPreferences storage;
//   final darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     scaffoldBackgroundColor: Colors.black,
//     primarySwatch: Colors.blue,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.black,
//       foregroundColor: Colors.white,
//     ),
//     textTheme: const TextTheme(
//       bodyLarge: TextStyle(color: Colors.white),
//       bodyMedium: TextStyle(color: Colors.white),
//     ),
//   );
//   final lightTheme = ThemeData(
//     brightness: Brightness.light,
//     scaffoldBackgroundColor: Colors.white,
//     primarySwatch: Colors.blue,
//   );
//   Future<void> init() async {
//     storage = await SharedPreferences.getInstance();
//     _isDark = storage.getBool("isDark") ?? false;
//     _themeMode = _isDark ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
//   void toggleTheme() {
//     _isDark = !_isDark;
//     _themeMode = _isDark ? ThemeMode.dark : ThemeMode.light;
//     storage.setBool("isDark", _isDark);
//     notifyListeners();
//   }
//   void setLightTheme() {
//     _isDark = false;
//     _themeMode = ThemeMode.light;
//     storage.setBool("isDark", false);
//     notifyListeners();
//   }
//   void setDarkTheme() {
//     _isDark = true;
//     _themeMode = ThemeMode.dark;
//     storage.setBool("isDark", true);
//     notifyListeners();
//   }
// }