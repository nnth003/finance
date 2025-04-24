// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class UpdateAvatarPage extends StatefulWidget {
//   const UpdateAvatarPage({super.key});
//
//   @override
//   State<UpdateAvatarPage> createState() => _UpdateAvatarPageState();
// }
//
// class _UpdateAvatarPageState extends State<UpdateAvatarPage> {
//   File? _image;
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _image = File(picked.path_
