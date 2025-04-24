// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../provider/ThemeProvider.dart';
//
// class ThemeSettingsPage extends StatelessWidget {
//   const ThemeSettingsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, _) {
//         return Scaffold(
//           appBar: AppBar(title: const Text("Giao diện")),
//           body: SwitchListTile(
//             title: const Text("Chế độ tối"),
//             value: themeProvider.isDark,
//             onChanged: (_) => themeProvider.toggleTheme(),
//           ),
//         );
//       },
//     );
//   }
// }