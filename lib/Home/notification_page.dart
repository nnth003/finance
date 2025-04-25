import 'package:finance/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';

import '../provider/ThemeProvider.dart';

// Define the Transaction class (unchanged)
class Transaction {
  final String id;
  final String title;
  final String description;
  final String date;
  final double amount;
  final String type;
  final String? category;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.amount,
    required this.type,
    this.category,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled',
      description: map['description']?.toString() ?? 'No description',
      date: map['date']?.toString() ?? 'No date',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type']?.toString() ?? 'Expense',
      category: map['category']?.toString(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool _notificationsTriggered = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon'); // Replace with your app icon

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Updated: Show notification with "pay" or "receive" based on transaction type
  Future<void> _showPaymentReminderNotification(Transaction transaction) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'payment_channel_id',
      'Payment Reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    // Customize message based on transaction type
    String message = transaction.type == 'Expense'
        ? 'You have to pay: ${transaction.description}'
        : 'You have to receive: ${transaction.title}';

    await _flutterLocalNotificationsPlugin.show(
      transaction.id.hashCode,
      'Payment Reminder',
      message,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: provider.transactionsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading transactions',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }

                final transactions = snapshot.data!
                    .map((item) => Transaction.fromMap(item))
                    .toList();
                final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                final todayTransactions =
                transactions.where((t) => t.date == today).toList();

                if (todayTransactions.isNotEmpty && !_notificationsTriggered) {
                  for (var transaction in todayTransactions) {
                    _showPaymentReminderNotification(transaction);
                  }
                  _notificationsTriggered = true;
                }

                return Scaffold(
                  backgroundColor:
                  isDarkMode ? const Color(0xFF121212) : Colors.white, // Đổi màu nền
                  appBar: AppBar(
                    title: Text(
                      'Notifications',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.white, // Đổi màu tiêu đề
                      ),
                    ),
                    backgroundColor:
                    isDarkMode ? const Color(0xFF1E1E1E) : Colors.blueAccent, // Đổi màu AppBar
                    iconTheme: IconThemeData(
                      color: isDarkMode ? Colors.white : Colors.white, // Đổi màu icon back
                    ),
                  ),
                  body: todayTransactions.isEmpty
                      ? EmptyNotificationsScreen(isDarkMode: isDarkMode) // Sửa tên class từ Empty.widget thành EmptyNotificationsScreen
                      : ListView.builder(
                    itemCount: todayTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = todayTransactions[index];
                      String actionText = transaction.type == 'Expense'
                          ? 'You have to pay ${transaction.title}'
                          : 'You have to receive ${transaction.title}';
                      return ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu icon
                        ),
                        title: Text(
                          transaction.title,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu tiêu đề
                          ),
                        ),
                        subtitle: Text(
                          actionText,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu phụ đề
                          ),
                        ),
                        trailing: Text(
                          transaction.date,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu ngày
                          ),
                        ),
                        tileColor: isDarkMode
                            ? const Color(0xFF1E1E1E)
                            : Colors.white, // Đổi màu nền ListTile
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tapped: ${transaction.title}',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản SnackBar
                                ),
                              ),
                              backgroundColor: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.black, // Đổi màu nền SnackBar
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class EmptyNotificationsScreen extends StatelessWidget {
  const EmptyNotificationsScreen({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white, // Đổi màu nền
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.notifications_off,
                size: 100,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400], // Đổi màu icon
              ),
              const Spacer(flex: 2),
              ErrorInfo(
                title: "No Payment Reminders",
                description:
                "You have no payments scheduled for today. We'll notify you when there are payments due.",
                btnText: "Check Again",
                isDarkMode: isDarkMode, // Truyền isDarkMode vào ErrorInfo
                press: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Checking for updates...',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản SnackBar
                        ),
                      ),
                      backgroundColor:
                      isDarkMode ? Colors.grey[800] : Colors.black, // Đổi màu nền SnackBar
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    super.key,
    required this.title,
    required this.description,
    this.button,
    this.btnText,
    required this.press,
    required this.isDarkMode,
  });

  final String title;
  final String description;
  final Widget? button;
  final String? btnText;
  final VoidCallback press;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu tiêu đề
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54, // Đổi màu mô tả
              ),
            ),
            const SizedBox(height: 16 * 2.5),
            button ??
                ElevatedButton(
                  onPressed: press,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor:
                    isDarkMode ? const Color(0xFF1E1E1E) : Colors.black, // Đổi màu nút
                    foregroundColor:
                    isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản/icon trên nút
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  child: Text(
                    btnText ?? "Retry".toUpperCase(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản
                    ),
                  ),
                ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}