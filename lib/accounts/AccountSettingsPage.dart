import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart';
import 'EditProfilePage.dart';
import 'ChangePasswordPage.dart';
import 'DeviceLoginPage.dart';
import 'LanguageSettingsPage.dart';
import 'ThemeSettingsPage.dart';
import 'UpdateAvatarPage.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt tài khoản"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Chỉnh sửa hồ sơ"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EditProfilePage())),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Đổi mật khẩu"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage())),
          ),
          // ListTile(
          //   leading: const Icon(Icons.notifications),
          //   title: const Text("Thông báo"),
          //   onTap: () => Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => const NotificationSettingsPage())),
          // ),
          // ListTile(
          //   leading: const Icon(Icons.privacy_tip),
          //   title: const Text("Quyền riêng tư"),
          //   onTap: () => Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => const PrivacySettingsPage())),
          // ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text("Thiết bị & đăng nhập"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DeviceLoginPage())),
          ),
          // ListTile(
          //   leading: const Icon(Icons.image),
          //   title: const Text("Cập nhật Avatar"),
          //   onTap: () => Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => const UpdateAvatarPage())),
          // ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Ngôn ngữ"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LanguageSettingsPage())),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Giao diện"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ThemeSettingsPage())),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Đăng xuất"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
