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
      // final transSnap =
      //     await _firestore
      //         .collection('users')
      //         .doc(user.uid)
      //         .collection('transactions')
      //         .where('date', isGreaterThanOrEqualTo: startStr)
      //         .where('date', isLessThanOrEqualTo: endStr)
      //         .where("type", isEqualTo: "Expense")
      //         .get();
      //         print(transSnap.docs.length);
            final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr)
          .get();
          print(snapshot);
   totalSpent = snapshot.docs.fold(
  0.0,
  (sum, doc) => sum + (doc['amount'] as num).toDouble(),
) * -1;

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
                  ],
                ),
              ),
    );
  }
}
