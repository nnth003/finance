import 'package:flutter/material.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giao diện")),
      body: SwitchListTile(
        title: const Text("Chế độ tối"),
        value: isDark,
        onChanged: (value) {
          setState(() => isDark = value);
          // TODO: Thay đổi ThemeMode toàn app (sử dụng Provider hoặc GetX...)
        },
      ),
    );
  }
}
