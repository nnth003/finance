import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});
  final _emailController = TextEditingController(text: FirebaseAuth.instance.currentUser?.email);

  void _resetPassword(BuildContext context) {
    FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email đổi mật khẩu đã được gửi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Chúng tôi sẽ gửi email để bạn thay đổi mật khẩu"),
            TextField(controller: _emailController, enabled: false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _resetPassword(context),
              child: const Text("Gửi email đổi mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }
}
