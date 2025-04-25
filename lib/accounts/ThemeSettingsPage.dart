import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/ThemeProvider.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Theme Settings',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.white, // Đổi màu tiêu đề
              ),
            ),
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blueAccent, // Đổi màu AppBar
            iconTheme: IconThemeData(
              color: isDarkMode ? Colors.white : Colors.white, // Đổi màu icon back
            ),
          ),
          backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white, // Đổi màu nền
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ListTile(
              //   title: Text(
              //     'System Default',
              //     style: TextStyle(
              //       color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu văn bản
              //     ),
              //   ),
              //   tileColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Đổi màu nền ListTile
              //   trailing: Radio<ThemeMode>(
              //     value: ThemeMode.system,
              //     groupValue: themeProvider.themeMode,
              //     onChanged: (value) {
              //       themeProvider.setSystemTheme();
              //     },
              //     activeColor: isDarkMode ? Colors.white : Colors.blue, // Đổi màu Radio khi được chọn
              //     fillColor: WidgetStateProperty.resolveWith((states) {
              //       if (!states.contains(WidgetState.selected)) {
              //         return isDarkMode ? Colors.white70 : Colors.black54; // Đổi màu Radio khi không được chọn
              //       }
              //       return null;
              //     }),
              //   ),
              //   onTap: () {
              //     themeProvider.setSystemTheme();
              //   },
              // ),
              ListTile(
                title: Text(
                  'Light Mode',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                tileColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(false);
                  },
                  activeColor: isDarkMode ? Colors.white : Colors.blue,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (!states.contains(WidgetState.selected)) {
                      return isDarkMode ? Colors.white70 : Colors.black54;
                    }
                    return null;
                  }),
                ),
                onTap: () {
                  themeProvider.toggleTheme(false);
                },
              ),
              ListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                tileColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(true);
                  },
                  activeColor: isDarkMode ? Colors.white : Colors.blue,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (!states.contains(WidgetState.selected)) {
                      return isDarkMode ? Colors.white70 : Colors.black54;
                    }
                    return null;
                  }),
                ),
                onTap: () {
                  themeProvider.toggleTheme(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}