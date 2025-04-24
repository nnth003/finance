import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

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
        const SnackBar(content: Text("Đã đăng xuất khỏi thiết bị hiện tại")),
      );
      Navigator.pop(context); // Quay về trang trước
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Thiết bị & đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Phiên đăng nhập hiện tại:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.devices),
              title: Text(_deviceInfo),
              subtitle: Text("Email: ${user?.email ?? 'Không rõ'}"),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _signOutCurrentDevice,
              icon: const Icon(Icons.logout),
              label: const Text("Đăng xuất khỏi thiết bị này"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 24),
            const Text(
              "Lưu ý: Firebase Authentication không hỗ trợ xem tất cả các thiết bị đã đăng nhập. "
              "Chức năng này chỉ áp dụng cho thiết bị hiện tại.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
