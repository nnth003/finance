import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SpendingPlanScreen extends StatefulWidget {
  const SpendingPlanScreen({super.key});

  @override
  State<SpendingPlanScreen> createState() => _SpendingPlanScreenState();
}

class _SpendingPlanScreenState extends State<SpendingPlanScreen> {
  double dailyTarget = 0;
  double totalSpent = 0;
  bool isLoading = true;
  String? filterType; // 'within' or 'exceed'

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final today = DateTime.now();
  late final DateTime startOfDay;
  late final DateTime endOfDay;

  @override
  void initState() {
    super.initState();
    startOfDay = DateTime(today.year, today.month, today.day);
    endOfDay = startOfDay.add(const Duration(days: 1));
    fetchPlanAndSpending();
  }

  Future<void> fetchPlanAndSpending() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Lấy mục tiêu trong ngày
      final planSnap =
          await _firestore
              .collection("users")
              .doc(user.uid)
              .collection("dailyPlans")
              .where("date", isGreaterThanOrEqualTo: startOfDay)
              .where("date", isLessThan: endOfDay)
              .get();

      if (planSnap.docs.isNotEmpty) {
        dailyTarget = (planSnap.docs.first.data()['target'] as num).toDouble();
      }

      final startStr =
          "${startOfDay.year}-${startOfDay.month.toString().padLeft(2, '0')}-${startOfDay.day.toString().padLeft(2, '0')}";
      final endStr =
          "${endOfDay.year}-${endOfDay.month.toString().padLeft(2, '0')}-${endOfDay.day.toString().padLeft(2, '0')}";

      // Tính tổng chi trong ngày
      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .where('date', isGreaterThanOrEqualTo: startStr)
              .where('date', isLessThanOrEqualTo: endStr)
              .get();
      for (var doc in snapshot.docs) {
        print('Transaction Data: ${doc.data()}');
        // Kiểm tra xem trường type có tồn tại và có giá trị là 'Income'
        if (doc['type'] == 'Expense') {
          totalSpent = totalSpent + (doc['amount'] as num).toDouble();
        }
      }

      totalSpent = totalSpent * -1;
      await saveDailyReport(user.uid);
      // Chuyển đổi thành số dương
    } catch (e) {
      print("Lỗi: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> setDailyTarget(double target) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("dailyPlans")
          .add({"date": startOfDay, "target": target});

      setState(() {
        dailyTarget = target;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mục tiêu đã được đặt thành công!")),
      );
    } catch (e) {
      print("Lỗi khi thêm mục tiêu: $e");
    }
  }

  Future<List<QueryDocumentSnapshot>> getFilteredTransactions(
    bool isExceeding,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final startStr =
          "${startOfDay.year}-${startOfDay.month.toString().padLeft(2, '0')}-${startOfDay.day.toString().padLeft(2, '0')}";
      final endStr =
          "${endOfDay.year}-${endOfDay.month.toString().padLeft(2, '0')}-${endOfDay.day.toString().padLeft(2, '0')}";

      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .where('date', isGreaterThanOrEqualTo: startStr)
              .where('date', isLessThanOrEqualTo: endStr)
              .get();

      return snapshot.docs.where((doc) {
        final amount = (doc['amount'] as num).toDouble() * -1;
        return isExceeding ? amount > dailyTarget : amount <= dailyTarget;
      }).toList();
    } catch (e) {
      print("Lỗi khi lọc giao dịch: $e");
      return [];
    }
  }

 Future<List<QueryDocumentSnapshot>> getFilteredTransactionsByTarget(
  bool isTargetMet,
) async {
  final user = _auth.currentUser;
  if (user == null) return [];
  print(isTargetMet);

  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyReports')
        .get();

    // Lọc giao dịch theo điều kiện isTargetMet
    final filteredDocs = snapshot.docs.where((doc) {
      if (isTargetMet) {
        return doc['isTargetMet'] == true;
      } else {
        return doc['isTargetMet'] == false;
      }
    }).toList();

    print("Giao dịch lọc: ${filteredDocs.length}");
    return filteredDocs;
  } catch (e) {
    print("Lỗi khi lọc giao dịch theo isTargetMet: $e");
    return [];
  }
}


  Future<void> saveDailyReport(String userId) async {
    try {
      // Kiểm tra xem báo cáo cho ngày hôm nay đã tồn tại chưa
      final existingReportSnap =
          await _firestore
              .collection("users")
              .doc(userId)
              .collection("dailyReports")
              .where("date", isGreaterThanOrEqualTo: startOfDay)
              .where("date", isLessThan: endOfDay)
              .get();

      // Nếu báo cáo đã tồn tại, update dữ liệu
      if (existingReportSnap.docs.isNotEmpty) {
        final existingReport = existingReportSnap.docs.first;
        await _firestore
            .collection("users")
            .doc(userId)
            .collection("dailyReports")
            .doc(existingReport.id)
            .update({
              "target": dailyTarget,
              "totalSpent": totalSpent,
              "isTargetMet":
                  dailyTarget >= totalSpent, // Thêm trường `isTargetMet`
            });
        print("Daily report updated!");
      } else {
        // Nếu báo cáo chưa tồn tại, tạo báo cáo mới
        await _firestore
            .collection("users")
            .doc(userId)
            .collection("dailyReports")
            .add({
              "date": Timestamp.fromDate(DateTime.now()), // Lưu ngày hiện tại
              "target": dailyTarget, // Mục tiêu chi tiêu
              "totalSpent": totalSpent, // Tổng chi tiêu trong ngày
              "isTargetMet":
                  dailyTarget >= totalSpent, // Thêm trường `isTargetMet`
            });
        print("Daily report saved!");
      }
    } catch (e) {
      print("Error saving/updating daily report: $e");
    }
  }

  void showTargetFilteredTransactions(bool isTargetMet) async {
    setState(() {
      isLoading = true;
    });

    // Lọc các giao dịch dựa trên target
    final transactions = await getFilteredTransactionsByTarget(isTargetMet);

    setState(() {
      isLoading = false;
    });

    // Chuyển đến màn hình hiển thị các giao dịch đã lọc
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FilteredTransactionsScreen(
              transactions: transactions,
              isTargetMet: isTargetMet,
              dailyTarget: dailyTarget,
            ),
      ),
    );
  }

  void showTargetDialog() {
    final TextEditingController targetController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Đặt mục tiêu chi tiêu"),
            content: TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Nhập số tiền (VD: 500000)",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () {
                  final target = double.tryParse(targetController.text);
                  if (target != null) {
                    setDailyTarget(target);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Lưu"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOver = totalSpent > dailyTarget;
    final formattedDate = DateFormat('dd/MM/yyyy').format(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kế hoạch chi tiêu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: "Đặt mục tiêu",
            onPressed: showTargetDialog,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hôm nay: $formattedDate",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: isOver ? Colors.red[100] : Colors.green[100],
                      child: ListTile(
                        title: Text(
                          "Đã chi: ${totalSpent.toStringAsFixed(0)}₫",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isOver ? Colors.red : Colors.green,
                          ),
                        ),
                        subtitle: Text(
                          "Mục tiêu: ${dailyTarget.toStringAsFixed(0)}₫",
                        ),
                        trailing:
                            isOver
                                ? const Icon(Icons.warning, color: Colors.red)
                                : const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => showTargetFilteredTransactions(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            "Trong mục tiêu",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => showTargetFilteredTransactions(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            "Vượt mục tiêu",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}

class FilteredTransactionsScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot> transactions;
  final bool isTargetMet;
  final double dailyTarget;

  const FilteredTransactionsScreen({
    super.key,
    required this.transactions,
    required this.isTargetMet,
    required this.dailyTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTargetMet
              ? "Giao dịch khi mục tiêu hoàn thành"
              : "Giao dịch vượt mục tiêu",
        ),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final isOver = transactions[index]['totalSpent'] < transactions[index]['target'];
              final transaction = transactions[index].data() as Map<String, dynamic>; // Chuyển đổi về kiểu Map<String, dynamic>

          print(transaction);
          return  Card(
                      color: isOver ? Colors.green[100] : Colors.red[100],
                      child: ListTile(
                        title: Text(
                          "Đã chi: ${transaction['totalSpent'].toStringAsFixed(0)}₫",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isOver ? Colors.red : Colors.green,
                          ),
                        ),
                        subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                         Text(
                          "Mục tiêu: ${transaction['target'].toStringAsFixed(0)}₫",
                        ),Text(
          "Ngày: ${DateFormat('dd/MM/yyyy').format((transaction['date'] as Timestamp).toDate())}",
          style: TextStyle(color: Colors.grey[700]),
        ),]),
                        trailing:
                            isOver
                                ? const Icon(Icons.warning, color: Colors.red)
                                : const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                      ),
                    );
        },
      ),
    );
  }
}

