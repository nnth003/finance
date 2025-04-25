import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/ChatAI/openai_service.dart';
import 'package:provider/provider.dart';
import '../provider/ThemeProvider.dart'; // Thêm import ThemeProvider

class ChatScreen extends StatefulWidget {
  final String? id;

  const ChatScreen({super.key, this.id});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final GeminiService _gemini = GeminiService();

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": input});
      _controller.clear();
    });

    final reply = await _gemini.sendMessage(input);

    setState(() {
      _messages.add({"role": "ai", "content": reply});
    });
  }

  Future<void> _handleFilter(String type) async {
    final now = DateTime.now();
    DateTime start, end;

    if (type == "day") {
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1));
    } else if (type == "week") {
      start = now.subtract(Duration(days: now.weekday - 1));
      end = start.add(const Duration(days: 7));
    } else if (type == "month") {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(
        now.month == 12 ? now.year + 1 : now.year,
        now.month % 12 + 1,
        1,
      );
    } else {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year + 1, 1, 1);
    }

    final data = await getTransactionsByTimeFrame(start, end);
    final summary = calculateTransactionSummary(data);

    final buffer = StringBuffer();
    buffer.writeln('💬 **Tóm tắt giao dịch** (${type.toUpperCase()})');
    buffer.writeln('📈 Thu nhập: ${summary['totalIncome']} ₫');
    buffer.writeln('📉 Chi tiêu: ${summary['totalExpense']} ₫');
    buffer.writeln('💰 Số dư: ${summary['balance']} ₫');
    buffer.writeln('\n📂 Theo danh mục:');
    summary['categories'].forEach((key, value) {
      buffer.writeln(' • $key: $value ₫');
    });
    buffer.writeln('\nPhân tích dữ liệu trên và đưa ra kế hoạch tiết kiệm.');

    setState(() {
      _controller.text = buffer.toString();
    });
  }

  Future<List<Map<String, dynamic>>> getTransactionsByTimeFrame(
      DateTime start,
      DateTime end,
      ) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final startStr =
          "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
      final endStr =
          "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

      final snapshot =
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Lỗi: $e');
      return [];
    }
  }

  Map<String, dynamic> calculateTransactionSummary(
      List<Map<String, dynamic>> transactions,
      ) {
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categories = {};

    for (final transaction in transactions) {
      final amount = transaction['amount'] as double;
      final type = transaction['type'] as String;
      final category = transaction['category']?.toString() ?? 'Other';

      if (type == 'Income') {
        totalIncome += amount;
      } else if (type == 'Expense') {
        totalExpense += amount;
      }

      categories[category] = (categories[category] ?? 0) + amount;
    }

    return {
      'categories': categories,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Chat Tài Chính'),
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blueAccent, // Đổi màu AppBar
            titleTextStyle: TextStyle(
              color: isDarkMode ? Colors.white : Colors.white, // Đổi màu tiêu đề
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(
              color: isDarkMode ? Colors.white : Colors.white, // Đổi màu icon back
            ),
            centerTitle: true,
          ),
          backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white, // Đổi màu nền
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilterChip(
                      label: Text(
                        'Ngày',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu văn bản
                        ),
                      ),
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200], // Đổi màu nền
                      selectedColor: isDarkMode ? Colors.grey[700] : Colors.blue[100], // Đổi màu khi được chọn
                      onSelected: (_) => _handleFilter("day"),
                    ),
                    FilterChip(
                      label: Text(
                        'Tuần',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                      selectedColor: isDarkMode ? Colors.grey[700] : Colors.blue[100],
                      onSelected: (_) => _handleFilter("week"),
                    ),
                    FilterChip(
                      label: Text(
                        'Tháng',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                      selectedColor: isDarkMode ? Colors.grey[700] : Colors.blue[100],
                      onSelected: (_) => _handleFilter("month"),
                    ),
                    FilterChip(
                      label: Text(
                        'Năm',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                      selectedColor: isDarkMode ? Colors.grey[700] : Colors.blue[100],
                      onSelected: (_) => _handleFilter("year"),
                    ),
                  ],
                ),
              ),
              Divider(
                color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu Divider
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';

                    final user = FirebaseAuth.instance.currentUser;
                    final userName = 'Bạn';
                    final userAvatar = user?.photoURL;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blueAccent, // Đổi màu avatar
                                child: Icon(
                                  Icons.android,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (isUser && userAvatar != null) ...[
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(userAvatar),
                              ),
                              const SizedBox(width: 6),
                            ] else if (isUser && userAvatar == null) ...[
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey, // Đổi màu avatar
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? (isDarkMode ? Colors.blueGrey[700] : Colors.blue[100]) // Đổi màu tin nhắn người dùng
                                      : (isDarkMode ? Colors.grey[800] : Colors.grey[200]), // Đổi màu tin nhắn AI
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isUser ? 16 : 0),
                                    bottomRight: Radius.circular(isUser ? 0 : 16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isUser ? userName : 'FinBot 🤖',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isUser
                                            ? (isDarkMode ? Colors.white : Colors.blueGrey) // Đổi màu tên người dùng
                                            : (isDarkMode ? Colors.white : Colors.deepPurple), // Đổi màu tên AI
                                      ),
                                    ),
                                    Text(
                                      message['content'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu nội dung tin nhắn
                                      ),
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
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100], // Đổi màu nền ô nhập liệu
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu hint
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu viền
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white70 : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.blue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black, // Đổi màu văn bản nhập vào
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: isDarkMode ? Colors.white : Colors.blue, // Đổi màu icon gửi
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}