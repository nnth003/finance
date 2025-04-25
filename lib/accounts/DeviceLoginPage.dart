import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../provider/ThemeProvider.dart'; // Thêm import ThemeProvider

class DeviceLoginPage extends StatefulWidget {
  const DeviceLoginPage({super.key});

  @override
  State<DeviceLoginPage> createState() => _DeviceLoginPageState();
}

class _DeviceLoginPageState extends State<DeviceLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _deviceInfo = "Đang tải thiết bị...";

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceDetails = "";
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      deviceDetails = "${info.manufacturer} ${info.model} (Android ${info.version.release})";
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      deviceDetails = "${info.name} ${info.model} (iOS ${info.systemVersion})";
    } else {
      deviceDetails = "Thiết bị không xác định";
    }

    setState(() {
      _deviceInfo = deviceDetails;
    });
  }

  Future<void> _signOutCurrentDevice() async {
    await _auth.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Đã đăng xuất khỏi thiết bị hiện tại",
            style: TextStyle(
              color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
                  ? Colors.white
                  : Colors.white, // Đổi màu văn bản SnackBar
            ),
          ),
          backgroundColor: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
              ? Colors.grey[800]
              : Colors.black, // Đổi màu nền SnackBar
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Thiết bị & đăng nhập",
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Phiên đăng nhập hiện tại:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu văn bản
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(
                    Icons.devices,
                    color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu icon
                  ),
                  title: Text(
                    _deviceInfo,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu tiêu đề
                    ),
                  ),
                  subtitle: Text(
                    "Email: ${user?.email ?? 'Không rõ'}",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu phụ đề
                    ),
                  ),
                  tileColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Đổi màu nền ListTile
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _signOutCurrentDevice,
                  icon: const Icon(Icons.logout),
                  label: const Text("Đăng xuất khỏi thiết bị này"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Giữ màu đỏ cho nút đăng xuất
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Lưu ý: Firebase Authentication không hỗ trợ xem tất cả các thiết bị đã đăng nhập. "
                      "Chức năng này chỉ áp dụng cho thiết bị hiện tại.",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu văn bản
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}