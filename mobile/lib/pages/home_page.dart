import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/components/product_card.dart';
import 'dart:convert';
import 'sidebar_menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _products = []; // List untuk menyimpan data produk
  List _categories = []; // List untuk menyimpan data kategori
  late String token; // Token untuk otentikasi
  final TextEditingController _searchController = TextEditingController(); // Controller untuk input pencarian produk
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key untuk validasi form

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    token = ModalRoute.of(context)!.settings.arguments as String; // Mengambil token dari arguments
    _fetchData(); // Memanggil fungsi untuk mengambil data produk dan kategori
  }

  // Fungsi untuk mengambil data produk dan kategori dari server
  Future<void> _fetchData() async {
    final responses = await Future.wait([_fetchProducts(), _fetchCategories()]);
    setState(() {
      _products = responses[0];
      _categories = responses[1];
    });
  }

  // Fungsi untuk mengambil data produk dari server
  Future<List> _fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/products'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch products'))); // Menampilkan pesan kesalahan jika gagal mengambil data produk
      return [];
    }
  }

  // Fungsi untuk mengambil data kategori dari server
  Future<List> _fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/categories'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch categories'))); // Menampilkan pesan kesalahan jika gagal mengambil data kategori
      return [];
    }
  }

  // Fungsi untuk mendapatkan nama kategori berdasarkan ID kategori
  String _getCategoryName(int categoryId) {
    final category = _categories.firstWhere(
      (category) => category['id'] == categoryId,
      orElse: () => {'name': 'Unknown'},
    );
    return category['name'];
  }

  // Fungsi untuk menyaring produk berdasarkan query pencarian
  List _filterProducts(String query) {
    if (query.isEmpty) {
      return _products;
    }
    final queryLower = query.toLowerCase();
    return _products.where((product) {
      final nameLower = product['name'].toString().toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();
  }

  // Fungsi untuk menambahkan produk baru
  Future<void> _addProduct() async {
    final productData = {
      'name': _nameController.text,
      'qty': int.parse(_qtyController.text),
      'categoryId': _selectedCategoryId,
      'url': _urlController.text,
      'createdBy': 'currentUser',
      'updatedBy': 'currentUser',
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/products'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productData),
    );

    if (response.statusCode == 201) {
      _fetchProducts();
      _nameController.clear();
      _qtyController.clear();
      _urlController.clear();
      _selectedCategoryId = null;
      Navigator.of(context).pop(); // Menutup dialog setelah produk berhasil ditambahkan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product'))); // Menampilkan pesan kesalahan jika gagal menambahkan produk
    }
  }

  // Fungsi untuk memperbarui data produk
  Future<void> _updateProduct(int productId) async {
    final productData = {
      'name': _nameController.text,
      'qty': int.parse(_qtyController.text),
      'categoryId': _selectedCategoryId,
      'url': _urlController.text,
      'createdBy': 'currentUser',
      'updatedBy': 'currentUser',
    };

    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/products/$productId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productData),
    );

    if (response.statusCode == 200) {
      _fetchProducts();
      Navigator.of(context).pop(); // Menutup dialog setelah produk berhasil diperbarui
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product'))); // Menampilkan pesan kesalahan jika gagal memperbarui produk
    }
  }

  // Fungsi untuk menghapus produk
  Future<void> _deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/products/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _products.removeWhere((product) => product['id'] == productId); // Menghapus produk dari list
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product'))); // Menampilkan pesan kesalahan jika gagal menghapus produk
    }
  }

  // Fungsi untuk menampilkan dialog tambah/edit produk
  void _showProductDialog({int? productId}) {
    if (productId != null) {
      final product = _products.firstWhere((p) => p['id'] == productId);
      _nameController.text = product['name'];
      _qtyController.text = product['qty'].toString();
      _selectedCategoryId = product['categoryId'].toString();
      _urlController.text = product['url'];
    } else {
      _nameController.clear();
      _qtyController.clear();
      _urlController.clear();
      _selectedCategoryId = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(productId == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _nameController,
                  icon: Icons.shopping_bag,
                  hintText: 'Product Name',
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a product name' : null,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _qtyController,
                  icon: Icons.inventory,
                  hintText: 'Quantity',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter the quantity';
                    if (int.tryParse(value) == null) return 'Please enter a valid number';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildDropdown(),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _urlController,
                  icon: Icons.image,
                  hintText: 'Image URL',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (productId == null) {
                  _addProduct();
                } else {
                  _updateProduct(productId);
                }
              }
            },
            child: Text(productId == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun TextFormField dengan kustomisasi
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple), // Ikon prefix
        hintText: hintText, // Hint teks
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // Widget untuk membangun DropdownButtonFormField dengan kustomisasi
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.category, color: Colors.deepPurple), // Ikon kategori
        hintText: 'Category', // Hint teks untuk dropdown
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      value: _selectedCategoryId,
      items: _categories.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem<String>(
          value: category['id'].toString(),
          child: Text(category['name']), // Nama kategori untuk dropdown
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value), // Mengubah nilai kategori yang dipilih
      validator: (value) => value == null ? 'Please select a category' : null, // Validasi untuk memastikan kategori terpilih
    );
  }

  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _qtyController = TextEditingController();
  late TextEditingController _urlController = TextEditingController();
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Warna latar belakang
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.white)), // Judul aplikasi
        backgroundColor: Colors.deepPurple, // Warna latar appbar
        iconTheme: const IconThemeData(color: Colors.white), // Tema ikon pada appbar
      ),
      drawer: SidebarMenu(token: token), // Menu samping
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurple), // Ikon pencarian
                  hintText: 'Search products...', // Hint teks untuk pencarian
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (query) => setState(() {}), // Memperbarui pencarian saat teks berubah
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filterProducts(_searchController.text).length,
                itemBuilder: (context, index) {
                  final product = _filterProducts(_searchController.text)[index];
                  final categoryName = _getCategoryName(product['categoryId']); // Mendapatkan nama kategori untuk produk tertentu

                  return ProductCard(
                    product: product,
                    categoryName: categoryName,
                    token: token,
                    onDelete: () => _deleteProduct(product['id']), // Menghapus produk
                    onEdit: () => _showProductDialog(productId: product['id']), // Menampilkan dialog edit produk
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(), // Tombol tambah produk
        backgroundColor: Colors.deepPurple, // Warna latar tombol tambah
        foregroundColor: Colors.white, // Warna ikon tombol tambah
        child: Icon(Icons.add), // Ikon tambah
      ),
    );
  }
}
