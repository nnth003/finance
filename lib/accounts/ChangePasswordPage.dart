import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: _currentPasswordController.text,
    );

    try {
      // Xác thực lại người dùng
      await user.reauthenticateWithCredential(cred);

      // Cập nhật mật khẩu mới
      await user.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đổi mật khẩu thành công")),
      );
      Navigator.of(context).pop(); // Quay lại sau khi đổi thành công
    } on FirebaseAuthException catch (e) {
      String message = "Đã có lỗi xảy ra.";
      if (e.code == 'wrong-password') {
        message = "Mật khẩu hiện tại không đúng.";
      } else if (e.code == 'weak-password') {
        message = "Mật khẩu mới quá yếu.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu hiện tại"),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null,
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu mới"),
                validator: (value) => value!.length < 6 ? 'Ít nhất 6 ký tự' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Nhập lại mật khẩu mới"),
                validator: (value) => value != _newPasswordController.text ? 'Mật khẩu không khớp' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _changePassword,
                child: const Text("Đổi mật khẩu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
