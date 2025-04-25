import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/ThemeProvider.dart';
import '../provider/transactionProvider.dart';
import 'notification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate(
      List<Map<String, dynamic>> transactions,
      ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final now = DateTime.now();

    for (var transaction in transactions) {
      final date = DateTime.parse(transaction['date']);
      String key;

      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        key = "Today";
      } else if (date.day == now.day - 1 &&
          date.month == now.month &&
          date.year == now.year) {
        key = "Yesterday";
      } else {
        key = "${date.day}/${date.month}/${date.year}";
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(transaction);
    }

    return grouped;
  }

  Map<String, double> calculateBalances(
      List<Map<String, dynamic>> transactions,
      ) {
    double totalBalance = 0;
    double income = 0;
    double expenses = 0;

    for (var t in transactions) {
      final amount = t['amount'] as double;
      totalBalance += amount;
      if (amount >= 0) {
        income += amount;
      } else {
        expenses += amount.abs();
      }
    }

    return {
      'totalBalance': totalBalance,
      'income': income,
      'expenses': expenses,
    };
  }

  Future<String> _getUserFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('user_info')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          return doc['first_name'] ?? 'User';
        }
      } catch (e) {
        debugPrint("Error fetching user name: $e");
      }
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: provider.transactionsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Error loading transactions')),
              );
            }

            final transactions = snapshot.data!;
            final balances = calculateBalances(transactions);
            final transactionsByDate = _groupTransactionsByDate(transactions);

            return Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final isDarkMode = themeProvider.isDarkMode;
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                    elevation: 0,
                    title: FutureBuilder<String>(
                      future: _getUserFirstName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "https://i.pravatar.cc/150?img=3",
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Loading...",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }
                        final userName = snapshot.data ?? 'User';
                        return Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage(
                                "https://i.pravatar.cc/150?img=3",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Hey, $userName!",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: Stack(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: const Color.fromARGB(255, 73, 176, 205),
                              size: 37,
                            ),
                            Positioned(
                              right: 6,
                              top: 7,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          currencyFormat.format(balances['totalBalance']),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Total Balance",
                          style: TextStyle(
                            fontSize: 16,
                            // Đổi màu chữ thành trắng trong chế độ tối để phù hợp với nền tối
                            color: isDarkMode ? Colors.white : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceCard(
                              "Income",
                              balances['income']!,
                              Icons.arrow_upward,
                              const Color.fromARGB(255, 6, 210, 111),
                            ),
                            _buildBalanceCard(
                              "Expense",
                              balances['expenses']!,
                              Icons.arrow_downward,
                              Colors.redAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Recent Transactions",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // Đổi màu chữ thành trắng trong chế độ tối để phù hợp với nền tối
                              color: isDarkMode ? Colors.white : const Color.fromARGB(255, 82, 80, 80),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: transactions.isEmpty
                              ? Center(
                            child: Text(
                              "No transactions yet.",
                              style: TextStyle(
                                fontSize: 16,
                                // Đổi màu chữ thành trắng trong chế độ tối để phù hợp với nền tối
                                color: isDarkMode ? Colors.white : Colors.grey,
                              ),
                            ),
                          )
                              : ListView(
                            padding: const EdgeInsets.only(top: 5),
                            children: transactionsByDate.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      // Đổi màu chữ thành trắng trong chế độ tối để phù hợp với nền tối
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ...entry.value.map(
                                        (transaction) => _buildTransactionCard(
                                      transaction["title"],
                                      transaction["description"] ??
                                          "${transaction['type']} - ${transaction['category'] ?? 'Uncategorized'}",
                                      transaction["amount"],
                                      _getIconForCategory(transaction["category"]),
                                      _getColorForType(transaction["type"]),
                                      transaction["date"],
                                      isDarkMode,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBalanceCard(
      String title,
      double amount,
      IconData icon,
      Color color,
      ) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: '₫',
                      ).format(amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(icon, color: Colors.white, size: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(
      String title,
      String desc,
      double amount,
      IconData icon,
      Color iconColor,
      String date,
      bool isDarkMode,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.white12 : Colors.black12,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.2),
                radius: 20,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      // Đổi màu chữ thành trắng trong chế độ tối để phù hợp với nền tối
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      // Đổi màu chữ thành trắng nhạt trong chế độ tối để phù hợp với nền tối
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: '₫',
                ).format(amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amount >= 0 ? Colors.green : Colors.red,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  // Đổi màu chữ thành trắng nhạt trong chế độ tối để phù hợp với nền tối
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String? category) {
    switch (category ?? 'Uncategorized') {
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Food':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_car;
      case 'Health':
        return Icons.healing;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills':
        return Icons.receipt;
      case 'Education':
        return Icons.school;
      case 'Salary':
        return Icons.attach_money;
      case 'Gift':
        return Icons.card_giftcard;
      case 'Investment':
        return Icons.trending_up;
      case 'Travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  Color _getColorForType(String? type) {
    switch (type ?? 'Uncategorized') {
      case 'Income':
        return Colors.green;
      case 'Expense':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}