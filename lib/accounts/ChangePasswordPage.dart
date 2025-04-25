import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../provider/ThemeProvider.dart'; // Thêm import ThemeProvider

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
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Đổi mật khẩu thành công",
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
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message = "Đã có lỗi xảy ra.";
      if (e.code == 'wrong-password') {
        message = "Mật khẩu hiện tại không đúng.";
      } else if (e.code == 'weak-password') {
        message = "Mật khẩu mới quá yếu.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
                  ? Colors.white
                  : Colors.white,
            ),
          ),
          backgroundColor: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
              ? Colors.grey[800]
              : Colors.black,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Đổi mật khẩu",
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu hiện tại",
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54, // Đổi màu nhãn
                      ),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white70 : Colors.black26, // Đổi màu viền
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black, // Đổi màu viền khi focus
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black, // Đổi màu văn bản nhập vào
                    ),
                    validator: (value) => value!.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null,
                  ),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu mới",
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white70 : Colors.black26,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    validator: (value) => value!.length < 6 ? 'Ít nhất 6 ký tự' : null,
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Nhập lại mật khẩu mới",
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white70 : Colors.black26,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    validator: (value) => value != _newPasswordController.text ? 'Mật khẩu không khớp' : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue, // Đổi màu nút
                      foregroundColor: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản/icon
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      "Đổi mật khẩu",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản nút
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}