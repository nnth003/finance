import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Home/notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';
import '../provider/ThemeProvider.dart';
import 'AccountSettingsPage.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF6366F1),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            fontFamily: 'Inter',
            textTheme: TextTheme(
              headlineSmall: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              bodyLarge: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          home: const ProfileScreen(),
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('user_info')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          return {
            'name': doc['first_name'] ?? 'User',
            'email': doc['email'] ?? user.email ?? 'No email',
            'phone': doc['phone_number'] ?? 'Not set'
          };
        }
      } catch (e) {
        debugPrint("Error fetching user info: $e");
      }
    }
    return {
      'name': 'User',
      'email': user?.email ?? 'No email',
      'phone': 'Not set'
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC), // Đổi màu nền cho chế độ tối
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blueAccent, // Đổi màu container cho chế độ tối
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black26 : Colors.black12,
                        blurRadius: 8.r,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.exit_to_app,
                          color: isDarkMode ? Colors.white : Colors.white, // Đổi màu icon
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: FutureBuilder<Map<String, String>>(
                    future: _getUserInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final userInfo = snapshot.data ?? {
                        'name': 'User',
                        'email': 'No email',
                        'phone': 'Not set'
                      };
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode ? const Color(0xFF424242) : const Color(0xFFE2E8F0), // Đổi màu viền
                                width: 2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? Colors.black54 : Colors.black.withOpacity(0.1),
                                  blurRadius: 12.r,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 48.r,
                              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Đổi màu nền avatar
                              backgroundImage: const AssetImage('assets/images/dr4.png'),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            userInfo['name']!,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : const Color(0xFF1E293B), // Đổi màu tên
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            userInfo['email']!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF64748B), // Đổi màu email
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            userInfo['phone']!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF64748B), // Đổi màu số điện thoại
                            ),
                          ),
                          SizedBox(height: 6.h),
                          OutlinedButton.icon(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 16.r,
                              color: isDarkMode ? Colors.white : const Color(0xFF6366F1), // Đổi màu icon
                            ),
                            label: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDarkMode ? Colors.white : const Color(0xFF6366F1), // Đổi màu văn bản
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDarkMode ? Colors.white : const Color(0xFF6366F1), // Đổi màu viền
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.transparent, // Đổi màu nền nút
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                    currentName: userInfo['name']!,
                                    currentEmail: userInfo['email']!,
                                    currentPhone: userInfo['phone']!,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Đổi màu container cho chế độ tối
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                    ),
                    child: ListView(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      children: [
                        _buildSectionHeader('Account', isDarkMode),
                        _buildListItem(
                          icon: FontAwesomeIcons.userGear,
                          title: 'Account Settings',
                          color: const Color(0xFF3B82F6),
                          isDarkMode: isDarkMode,
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountSettingsPage(),
                              ),
                            );
                          },
                        ),
                        _buildListItem(
                          icon: FontAwesomeIcons.bell,
                          title: 'Notifications',
                          color: const Color(0xFFF59E0B),
                          isDarkMode: isDarkMode,
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white70 : const Color(0xFF64748B), // Đổi màu tiêu đề phần
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required bool isDarkMode,
    required VoidCallback ontap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          size: 20.r,
          color: color, // Giữ màu icon cố định
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : const Color(0xFF1E293B), // Đổi màu tiêu đề
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: isDarkMode ? Colors.white70 : const Color(0xFF94A3B8), // Đổi màu phụ đề
        ),
      )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20.r,
        color: isDarkMode ? Colors.white70 : const Color(0xFFCBD5E1), // Đổi màu icon
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      onTap: ontap,
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentPhone;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('user_info')
            .doc(user.uid)
            .update({
          'first_name': _nameController.text,
          'email': _emailController.text,
          'phone_number': _phoneController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC), // Đổi màu nền
          appBar: AppBar(
            title: Text(
              'Edit Profile',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu tiêu đề AppBar
              ),
            ),
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Đổi màu AppBar
            iconTheme: IconThemeData(
              color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu icon back
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
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
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
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
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF6366F1), // Đổi màu nút
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản nút
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}