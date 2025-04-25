import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Analytics/analytics.dart';
import 'package:finance/ChatAI/chat_screen.dart';
import 'package:finance/Home/home_page.dart';
import 'package:finance/accounts/account_page.dart';
import 'package:finance/category/category_page.dart';
import 'package:finance/plan/plan_page.dart';
import 'package:finance/provider/ThemeProvider.dart';
import 'package:finance/provider/transactionProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

import 'Payment/payment_config.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isPlanUnlocked = false;

  @override
  void initState() {
    super.initState();
    _checkPlanUnlocked();
    print("Hello: $_isPlanUnlocked");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    final List<Widget> pages = [
      const DashboardScreen(),
      const AnalyticsPage(),
      const CategoryManagementPage(),
      const ChatScreen(),
      _buildPlanPageWithLock(),
      const AccountPage(),
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Màu nền thay đổi theo chế độ tối/sáng
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black54 : Colors.black12, // Đổi màu bóng theo chế độ
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: GNav(
                    gap: 8,
                    backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Màu nền GNav
                    color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 12, 154, 236), // Màu icon khi không được chọn
                    activeColor: Colors.white, // Màu icon khi được chọn
                    tabBackgroundColor: isDarkMode ? Colors.grey[700]! : Colors.grey[800]!, // Màu nền tab khi được chọn
                    padding: const EdgeInsets.all(10),
                    onTabChange: _onItemTapped,
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white : Colors.white, // Màu văn bản của tab
                    ),
                    tabs: const [
                      GButton(icon: Icons.home, text: 'Home'),
                      GButton(icon: Icons.analytics, text: 'Analytics'),
                      GButton(icon: Icons.category, text: 'Categories'),
                      GButton(icon: Icons.adb, text: 'Chat Ai'),
                      GButton(icon: Icons.text_snippet, text: 'Plan'),
                      GButton(icon: Icons.person, text: 'Accounts'),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      transactionProvider.showTransactionDialog(context);
                    },
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, size: 32, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanPageWithLock() {
    if (_isPlanUnlocked) return const SpendingPlanScreen();

    return Stack(
      children: [
        const SpendingPlanScreen(),
        Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Chức năng này yêu cầu mở khóa",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Platform.isIOS ? _buildApplePay() : _buildGooglePay(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplePay() {
    return ApplePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(defaultApplePay),
      paymentItems: const [
        PaymentItem(
          label: 'Mở khóa tính năng Plan',
          amount: '0.01',
          status: PaymentItemStatus.final_price,
        ),
      ],
      style: ApplePayButtonStyle.black,
      width: 250,
      height: 50,
      type: ApplePayButtonType.buy,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: (result) {
        debugPrint('ApplePay Success: $result');
        setState(() => _isPlanUnlocked = true);
      },
      loadingIndicator: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildGooglePay() {
    return GooglePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
      paymentItems: const [
        PaymentItem(
          label: 'Mở khóa tính năng Plan',
          amount: '0.01',
          status: PaymentItemStatus.final_price,
        ),
      ],
      type: GooglePayButtonType.pay,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: (result) {
        if (result['paymentMethodData'] != null) {
          _updateProfile();
          setState(() => _isPlanUnlocked = true);
          debugPrint('GooglePay Success: $result');
        }
      },
      loadingIndicator: const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('user_info')
          .doc(user.uid)
          .update({'payment': "1"});
    }
  }

  Future<void> _checkPlanUnlocked() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('user_info')
          .doc(user.uid)
          .get();

      final data = doc.data();
      print("Datacc: $data");
      if (data != null && data['payment'] == "1") {
        print("check3424324324324: ${data['payment']}");
        setState(() => _isPlanUnlocked = true);
      }
    }
  }
}