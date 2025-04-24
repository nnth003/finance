import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;

  File? _avatarImage;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(_user?.uid).get();
    if (doc.exists) {
      _nameController.text = doc['name'] ?? '';
      _avatarUrl = doc['avatar'];
    }
    _emailController.text = _user?.email ?? '';
    setState(() {});
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      String? uploadedUrl;

      if (_avatarImage != null) {
        final ref = FirebaseStorage.instance.ref('avatars/${_user!.uid}.jpg');
        await ref.putFile(_avatarImage!);
        uploadedUrl = await ref.getDownloadURL();
      }

      final updates = {
        'name': _nameController.text,
        if (uploadedUrl != null) 'avatar': uploadedUrl,
      };

      await FirebaseFirestore.instance.collection('users').doc(_user?.uid).update(updates);

      if (_emailController.text != _user?.email) {
        await _user?.updateEmail(_emailController.text);
      }

      if (_passwordController.text.isNotEmpty) {
        await _user?.updatePassword(_passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa hồ sơ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatarImage != null
                    ? FileImage(_avatarImage!)
                    : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null) as ImageProvider?,
                child: _avatarImage == null && _avatarUrl == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Tên"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Mật khẩu mới"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProfile, child: const Text("Lưu thay đổi")),
          ],
        ),
      ),
    );
  }
}
