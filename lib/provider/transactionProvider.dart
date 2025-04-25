import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/provider/category_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ThemeProvider.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> get transactionsStream {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  void showTransactionDialog(BuildContext context, {String? id}) {
    showDialog(
      context: context,
      builder: (context) {
        return TransactionDialog(
          id: id,
          onSave: () {
            notifyListeners();
          },
        );
      },
    );
  }

  Future<void> deleteTransaction(String id) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(id)
          .delete();
      notifyListeners();
    }
  }
}

class TransactionDialog extends StatefulWidget {
  final String? id;
  final VoidCallback onSave;

  const TransactionDialog({super.key, this.id, required this.onSave});

  @override
  _TransactionDialogState createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  String? _type = 'Expense';
  String? _category;
  DateTime? _date;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _date = DateTime.now();

    if (widget.id != null) {
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .doc(widget.id)
              .get();
      if (doc.exists) {
        final transaction = doc.data()!;
        setState(() {
          _titleController.text = transaction['title'];
          _amountController.text = transaction['amount'].abs().toString();
          _type = transaction['type'];
          _category = transaction['category'];
          _date = DateTime.parse(transaction['date']);
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user != null) {
        final transaction = {
          'title': _titleController.text,
          'amount':
              _type == 'Income'
                  ? double.parse(_amountController.text)
                  : -double.parse(_amountController.text),
          'type': _type,
          'category': _category,
          'date': _date!.toIso8601String().split('T')[0],
        };

        if (widget.id != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .doc(widget.id)
              .update(transaction);
        } else {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .add(transaction);
        }
        widget.onSave();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final List<String> categories = categoryProvider.categories;

    // Sử dụng Consumer<ThemeProvider> để lấy trạng thái chế độ sáng/tối
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return AlertDialog(
          title: Text(
            widget.id == null ? 'Add Transaction' : 'Edit Transaction',
            // Đổi màu tiêu đề thành trắng trong chế độ tối
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      // Đổi màu nhãn thành trắng trong chế độ tối
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    style: TextStyle(
                      // Đổi màu văn bản nhập vào thành trắng trong chế độ tối
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    validator:
                        (value) => value!.isEmpty ? 'Enter a title' : null,
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter an amount';
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _type,
                    items:
                        ['Income', 'Expense']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    // Đổi màu các mục trong dropdown thành trắng trong chế độ tối
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _type = value),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    style: TextStyle(
                      // Đổi màu giá trị hiển thị của dropdown thành trắng trong chế độ tối
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    dropdownColor:
                        isDarkMode
                            ? Colors
                                .grey[800] // Đổi màu nền dropdown trong chế độ tối
                            : Colors.white,
                  ),
                  DropdownButtonFormField<String>(
                    value: _category,
                    items:
                        categories
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _category = value),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    hint: Text(
                      'Select a category',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  ),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _date!.toIso8601String().split('T')[0],
                          style: TextStyle(
                            // Đổi màu văn bản ngày thành trắng trong chế độ tối
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            // Đổi màu icon thành trắng trong chế độ tối
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date!,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => _date = picked);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  // Đổi màu nút "Cancel" thành trắng trong chế độ tối
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: _saveTransaction,
              child: Text(
                widget.id == null ? 'Add' : 'Save',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
