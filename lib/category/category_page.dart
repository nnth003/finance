import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/category_provider.dart';
import '../provider/ThemeProvider.dart'; // Thêm import ThemeProvider

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  _CategoryManagementPageState createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final TextEditingController _categoryController = TextEditingController();
  String? _editingCategory;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _showAddEditDialog(
      BuildContext context,
      CategoryProvider provider, {
        bool isEditing = false,
      }) {
    if (!isEditing) {
      _categoryController.clear();
    }

    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Đổi màu nền AlertDialog
          title: Text(
            isEditing ? 'Edit Category' : 'Add Category',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu tiêu đề
            ),
          ),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              hintText: 'Enter category name',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu hint
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Đổi màu nút
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newCategory = _categoryController.text.trim();
                if (isEditing && _editingCategory != null) {
                  await provider.editCategory(_editingCategory!, newCategory);
                  _editingCategory = null;
                } else {
                  await provider.addCategory(newCategory);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                isEditing ? 'Save' : 'Add',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      _categoryController.clear();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        return Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Category Management',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.white, // Đổi màu tiêu đề
                  ),
                ),
                backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blueAccent, // Đổi màu AppBar
                iconTheme: IconThemeData(
                  color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu icon back
                ),
                elevation: 0,
              ),
              backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white, // Đổi màu nền
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _showAddEditDialog(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue, // Đổi màu nút
                          foregroundColor: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản/icon
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Add New Category',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.white, // Đổi màu văn bản
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: provider.categories.isEmpty
                          ? Center(
                        child: Text(
                          'No categories yet. Add one to get started!',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.grey, // Đổi màu văn bản
                          ),
                        ),
                      )
                          : ListView.builder(
                        itemCount: provider.categories.length,
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, // Đổi màu Card
                            child: ListTile(
                              title: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.white : Colors.black87, // Đổi màu tiêu đề
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: isDarkMode ? Colors.white : Colors.blue, // Đổi màu icon
                                    ),
                                    onPressed: () {
                                      _editingCategory = category;
                                      _categoryController.text = category;
                                      _showAddEditDialog(
                                        context,
                                        provider,
                                        isEditing: true,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: isDarkMode ? Colors.white70 : Colors.red, // Đổi màu icon
                                    ),
                                    onPressed: () => provider.deleteCategory(category),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}