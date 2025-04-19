import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/ChatAI/openai_service.dart';

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
      end = DateTime(now.month == 12 ? now.year + 1 : now.year, now.month % 12 + 1, 1);
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
      DateTime start, DateTime end) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final startStr = "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
      final endStr = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

      final snapshot = await _firestore
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

  Map<String, dynamic> calculateTransactionSummary(List<Map<String, dynamic>> transactions) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Tài Chính'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Các nút filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(label: Text('Ngày'), onSelected: (_) => _handleFilter("day")),
                FilterChip(label: Text('Tuần'), onSelected: (_) => _handleFilter("week")),
                FilterChip(label: Text('Tháng'), onSelected: (_) => _handleFilter("month")),
                FilterChip(label: Text('Năm'), onSelected: (_) => _handleFilter("year")),
              ],
            ),
          ),
          const Divider(),
          // Danh sách tin nhắn
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
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.android, color: Colors.white, size: 18),
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
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue[100] : Colors.grey[200],
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
                          color: isUser ? Colors.blueGrey : Colors.deepPurple,
                        ),
                      ),
                      Text(
                        message['content'] ?? '',
                        style: const TextStyle(fontSize: 16),
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

          // Ô nhập liệu + nút gửi
         Container(
  padding: const EdgeInsets.all(8),
  color: Colors.grey[100],
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Nhập tin nhắn...',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey), // Viền mặc định
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2), // Viền khi focus
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.send),
        color: Colors.blue,
        onPressed: _sendMessage,
      )
    ],
  ),
)

        ],
      ),
    );
  }
}
