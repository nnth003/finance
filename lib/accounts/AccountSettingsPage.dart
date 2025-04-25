import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login.dart';
import 'EditProfilePage.dart';
import 'ChangePasswordPage.dart';
import 'DeviceLoginPage.dart';
import 'LanguageSettingsPage.dart';
import 'ThemeSettingsPage.dart';
import 'UpdateAvatarPage.dart';
import '../provider/ThemeProvider.dart'; // Thêm import ThemeProvider

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Account Setting"),
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue, // Đổi màu AppBar
            titleTextStyle: TextStyle(
              color: isDarkMode ? Colors.white : Colors.white, // Đổi màu tiêu đề
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(
              color: isDarkMode ? Colors.white : Colors.white, // Đổi màu icon back
            ),
          ),
          backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white, // Đổi màu nền Scaffold
          body: ListView(
            children: [
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu icon
                ),
                title: Text(
                  "Change Password",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu văn bản
                  ),
                ),
                tileColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Đổi màu nền ListTile
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.devices,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                title: Text(
                  "Devices and Login",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                tileColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeviceLoginPage()),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.color_lens,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                title: Text(
                  "Theme",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                tileColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemeSettingsPage()),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                title: Text(
                  "Log out",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                tileColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}