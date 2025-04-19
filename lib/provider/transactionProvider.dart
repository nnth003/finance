import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/provider/category_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Ensure this exists

class TransactionProvider with ChangeNotifier { // Lớp quản lý các giao dịch, kế thừa `ChangeNotifier` để thông báo khi có thay đổi.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Khởi tạo đối tượng Firestore để truy cập cơ sở dữ liệu.
  final FirebaseAuth _auth = FirebaseAuth.instance; // Khởi tạo đối tượng FirebaseAuth để xác thực người dùng.

  Stream<List<Map<String, dynamic>>> get transactionsStream { // Stream để lấy danh sách giao dịch từ Firebase.
    final user = _auth.currentUser; // Lấy thông tin người dùng hiện tại.
    if (user == null) { // Nếu người dùng chưa đăng nhập, trả về một stream rỗng.
      return const Stream.empty();
    }
    return _firestore
        .collection('users') // Truy cập vào collection `users` trong Firestore.
        .doc(user.uid) // Dùng UID người dùng hiện tại để truy cập tài liệu của họ.
        .collection('transactions') // Truy cập vào collection `transactions` (giao dịch của người dùng).
        .snapshots() // Lắng nghe các thay đổi trong collection này.
        .map((snapshot) { // Chuyển đổi snapshot thành danh sách các giao dịch.
      return snapshot.docs.map((doc) {
        final data = doc.data(); // Lấy dữ liệu từ mỗi tài liệu.
        data['id'] = doc.id; // Thêm ID tài liệu vào dữ liệu.
        return data; // Trả về dữ liệu.
      }).toList();
    });
  }

  void showTransactionDialog(BuildContext context, {String? id}) { // Hiển thị hộp thoại để thêm hoặc chỉnh sửa giao dịch.
    showDialog(
      context: context,
      builder: (context) {
        return TransactionDialog(
          id: id, // Truyền ID nếu có, để xác định giao dịch cần chỉnh sửa.
          onSave: () {
            notifyListeners(); // Khi lưu xong, thông báo với các lắng nghe để cập nhật giao diện.
          },
        );
      },
    );
  }

  Future<void> deleteTransaction(String id) async { // Hàm xóa giao dịch theo ID.
    final user = _auth.currentUser; // Lấy người dùng hiện tại.
    if (user != null) { // Kiểm tra nếu người dùng đã đăng nhập.
      await _firestore
          .collection('users') // Truy cập collection `users`.
          .doc(user.uid) // Dùng UID người dùng.
          .collection('transactions') // Truy cập collection `transactions`.
          .doc(id) // Lấy tài liệu giao dịch theo ID.
          .delete(); // Xóa tài liệu.
      notifyListeners(); // Thông báo các lắng nghe để cập nhật giao diện.
    }
  }
}


class TransactionDialog extends StatefulWidget { // Định nghĩa một StatefulWidget để hiển thị hộp thoại thêm/chỉnh sửa giao dịch.
  final String? id; // ID của giao dịch nếu có (để chỉnh sửa).
  final VoidCallback onSave; // Hàm callback khi lưu giao dịch.

  const TransactionDialog({super.key, this.id, required this.onSave}); // Constructor của lớp, nhận vào ID và callback.

  @override
  _TransactionDialogState createState() => _TransactionDialogState(); // Tạo đối tượng state cho widget.
}

class _TransactionDialogState extends State<TransactionDialog> { // State của TransactionDialog.
  final _formKey = GlobalKey<FormState>(); // Khóa toàn cục cho form để xác nhận dữ liệu.
  late final TextEditingController _titleController; // Controller cho trường tiêu đề.
  late final TextEditingController _amountController; // Controller cho trường số tiền.
  String? _type = 'Expense'; // Loại giao dịch (Chi phí hoặc Thu nhập).
  String? _category; // Danh mục giao dịch.
  DateTime? _date; // Ngày giao dịch.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Khởi tạo đối tượng Firestore.
  final FirebaseAuth _auth = FirebaseAuth.instance; // Khởi tạo đối tượng FirebaseAuth.

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(); // Khởi tạo controller cho tiêu đề.
    _amountController = TextEditingController(); // Khởi tạo controller cho số tiền.
    _date = DateTime.now(); // Khởi tạo ngày giao dịch mặc định là ngày hiện tại.

    if (widget.id != null) { // Nếu có ID, nghĩa là chúng ta cần chỉnh sửa giao dịch.
      _loadTransaction(); // Tải dữ liệu giao dịch hiện tại.
    }
  }

  Future<void> _loadTransaction() async { // Hàm tải giao dịch từ Firestore.
    final user = _auth.currentUser; // Lấy người dùng hiện tại.
    if (user != null) { // Nếu người dùng đã đăng nhập.
      final doc = await _firestore
          .collection('users') // Truy cập collection `users`.
          .doc(user.uid) // Lấy tài liệu của người dùng.
          .collection('transactions') // Truy cập collection `transactions`.id
          .doc(widget.id) // Lấy giao dịch theo ID.
          .get(); // Lấy tài liệu.
      if (doc.exists) { // Nếu tài liệu tồn tại.
        final transaction = doc.data()!; // Lấy dữ liệu giao dịch.
        setState(() {
          _titleController.text = transaction['title']; // Điền tiêu đề vào controller.
          _amountController.text = transaction['amount'].abs().toString(); // Điền số tiền vào controller (dùng `abs` để tránh số âm).
          _type = transaction['type']; // Lấy loại giao dịch (Thu nhập/Chi phí).
          _category = transaction['category']; // Lấy danh mục giao dịch.
          _date = DateTime.parse(transaction['date']); // Chuyển đổi chuỗi ngày thành đối tượng DateTime.
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose(); // Giải phóng bộ điều khiển khi widget bị hủy.
    _amountController.dispose(); // Giải phóng bộ điều khiển khi widget bị hủy.
    super.dispose();
  }

  Future<void> _saveTransaction() async { // Hàm lưu giao dịch vào Firestore.
    if (_formKey.currentState!.validate()) { // Kiểm tra tính hợp lệ của form.
      final user = _auth.currentUser; // Lấy người dùng hiện tại.
      if (user != null) { // Nếu người dùng đã đăng nhập.
        final transaction = {
          'title': _titleController.text, // Lấy tiêu đề từ controller.
          'amount': _type == 'Income' // Kiểm tra nếu là thu nhập thì giữ nguyên số tiền, nếu là chi phí thì lấy giá trị âm.
              ? double.parse(_amountController.text)
              : -double.parse(_amountController.text),
          'type': _type, // Loại giao dịch (Thu nhập/Chi phí).
          'category': _category, // Danh mục giao dịch.
          'date': _date!.toIso8601String().split('T')[0], // Ngày giao dịch (chuyển đổi thành chuỗi theo định dạng ISO).
        };

        if (widget.id != null) { // Nếu có ID, chỉnh sửa giao dịch.
          await _firestore
              .collection('users') // Truy cập collection `users`.
              .doc(user.uid) // Lấy tài liệu của người dùng.
              .collection('transactions') // Truy cập collection `transactions`.
              .doc(widget.id) // Lấy giao dịch theo ID.
              .update(transaction); // Cập nhật giao dịch.
        } else { // Nếu không có ID, thêm mới giao dịch.
          await _firestore
              .collection('users') // Truy cập collection `users`.
              .doc(user.uid) // Lấy tài liệu của người dùng.
              .collection('transactions') // Truy cập collection `transactions`.
              .add(transaction); // Thêm giao dịch mới.
        }
        widget.onSave(); // Gọi callback khi giao dịch đã được lưu.
        Navigator.of(context).pop(); // Đóng hộp thoại sau khi lưu.
      }
    }
  }

  @override
  Widget build(BuildContext context) { // Xây dựng giao diện của hộp thoại.
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false); // Lấy danh mục từ provider.
    final List<String> categories = categoryProvider.categories; // Lấy danh sách các danh mục.

    return AlertDialog( // Hộp thoại hiển thị.
      title: Text(widget.id == null ? 'Add Transaction' : 'Edit Transaction'), // Tiêu đề thay đổi tùy thuộc vào ID.
      content: Form( // Form nhập liệu.
        key: _formKey, // Khóa form.
        child: SingleChildScrollView( // Cho phép cuộn nếu nội dung quá dài.
          child: Column( // Các trường nhập liệu trong form.
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField( // Trường nhập tiêu đề.
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField( // Trường nhập số tiền.
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter an amount';
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>( // Trường chọn loại giao dịch (Thu nhập/Chi phí).
                value: _type,
                items: ['Income', 'Expense']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<String>( // Trường chọn danh mục giao dịch.
                value: _category,
                items: categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                decoration: const InputDecoration(labelText: 'Category'),
                hint: const Text('Select a category'),
              ),
              InputDecorator( // Trường chọn ngày giao dịch.
                decoration: const InputDecoration(labelText: 'Date'),
                child: Row(
                  children: [
                    Text(_date!.toIso8601String().split('T')[0]), // Hiển thị ngày hiện tại.
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _date = picked); // Chọn ngày mới.
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [ // Các nút hành động.
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Hủy và đóng hộp thoại.
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveTransaction, // Lưu giao dịch.
          child: Text(widget.id == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
