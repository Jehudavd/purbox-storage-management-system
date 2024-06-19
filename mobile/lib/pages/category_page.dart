import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sidebar_menu.dart';
import 'package:mobile/components/category_dialog.dart';
import 'package:mobile/components/category_card.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List _categories = []; // List untuk menyimpan kategori
  final TextEditingController _nameController = TextEditingController(); // Controller untuk input nama kategori
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key untuk validasi form
  late String token; // Token untuk otentikasi

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mendapatkan token dari arguments
    token = ModalRoute.of(context)!.settings.arguments as String;
    // Memanggil fungsi untuk mengambil kategori dari server
    _fetchCategories();
  }

  // Fungsi untuk mengambil data kategori dari server
  Future<void> _fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/categories'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _categories = jsonDecode(response.body); // Memperbarui list kategori dengan data yang diterima dari server
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch categories'))); // Menampilkan snackbar jika gagal mengambil data kategori
    }
  }

  // Fungsi untuk menambahkan kategori baru
  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/categories'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'name': _nameController.text,
        }),
      );

      if (response.statusCode == 201) {
        _fetchCategories(); // Memperbarui list kategori setelah menambahkan kategori baru
        _nameController.clear(); // Mengosongkan input field setelah menambahkan kategori
        Navigator.of(context).pop(); // Menutup dialog setelah menambahkan kategori
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add category'))); // Menampilkan snackbar jika gagal menambahkan kategori
      }
    }
  }

  // Fungsi untuk menghapus kategori
  Future<void> _deleteCategory(int categoryId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/categories/$categoryId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      _fetchCategories(); // Memperbarui list kategori setelah menghapus kategori
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete category'))); // Menampilkan snackbar jika gagal menghapus kategori
    }
  }

  // Fungsi untuk menampilkan dialog penambahan kategori
  void _showAddCategoryDialog() {
    _nameController.clear(); // Mengosongkan input field sebelum menampilkan dialog

    showDialog(
      context: context,
      builder: (context) => CategoryDialog(
        nameController: _nameController,
        formKey: _formKey,
        onSave: _addCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Categories', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: SidebarMenu(token: token), // Sidebar menu
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length, // Jumlah item dalam list
                itemBuilder: (context, index) {
                  return CategoryCard(
                    category: _categories[index], // Kategori yang akan ditampilkan
                    onDelete: (categoryId) => _deleteCategory(categoryId), // Fungsi untuk menghapus kategori
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog, 
        backgroundColor: Colors.deepPurple, 
        foregroundColor: Colors.white, 
        child: Icon(Icons.add), 
      ),
    );
  }
}
