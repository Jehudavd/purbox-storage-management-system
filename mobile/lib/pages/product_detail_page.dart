import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan argumen yang dilewatkan saat navigasi
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final int productId = arguments['productId']; // ID produk
    final String token = arguments['token']; // Token autentikasi

    // Fungsi untuk mengambil detail produk dari server
    Future<Map<String, dynamic>> _fetchProductDetails() async {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/products/$productId'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load product details');
      }
    }

    // Fungsi untuk mengambil daftar kategori dari server
    Future<List<dynamic>> _fetchCategories() async {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/categories'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load categories');
      }
    }

    // Fungsi untuk mendapatkan nama kategori berdasarkan ID kategori
    String _getCategoryName(int categoryId, List<dynamic> categories) {
      final category = categories.firstWhere(
          (category) => category['id'] == categoryId,
          orElse: () => {'name': 'Unknown'});
      return category['name'];
    }

    // Fungsi untuk memformat tanggal
    String _formatDate(String dateStr) {
      final DateTime dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    }

    // Widget untuk menampilkan satu baris informasi
    Widget _buildInfoRow(IconData icon, String label, String value) {
      return Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future:
            _fetchProductDetails(), // Future untuk mendapatkan detail produk
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator jika data masih dimuat
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Tampilkan pesan error jika terjadi kesalahan
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            // Tampilkan pesan jika tidak ada produk yang ditemukan
            return Center(child: Text('No product found'));
          } else {
            // Jika data berhasil dimuat, tampilkan detail produk
            final product = snapshot.data!;
            return FutureBuilder<List<dynamic>>(
              future:
                  _fetchCategories(), // Future untuk mendapatkan daftar kategori
              builder: (context, categorySnapshot) {
                if (categorySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  // Loading indicator jika daftar kategori masih dimuat
                  return Center(child: CircularProgressIndicator());
                } else if (categorySnapshot.hasError) {
                  // Tampilkan pesan error jika terjadi kesalahan
                  return Center(
                      child: Text('Error: ${categorySnapshot.error}'));
                } else if (!categorySnapshot.hasData) {
                  // Tampilkan pesan jika tidak ada kategori yang ditemukan
                  return Center(child: Text('No categories found'));
                } else {
                  // Jika daftar kategori berhasil dimuat, tampilkan detail produk
                  final categories = categorySnapshot.data!;
                  final categoryName =
                      _getCategoryName(product['categoryId'], categories);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header dengan gambar produk dan judul
                        Stack(
                          children: [
                            product['url'] != null && product['url'].isNotEmpty
                                ? Image.network(
                                    product['url'],
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 250,
                                    color: Colors.grey,
                                    child: Center(
                                      child: Text(
                                        'No Image',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ),
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black54, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Text(
                                product['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Detail produk
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Informasi produk seperti kategori, jumlah, dll
                                  _buildInfoRow(Icons.category_outlined,
                                      'Category', categoryName),
                                  SizedBox(height: 10),
                                  _buildInfoRow(Icons.inventory_outlined, 'Qty',
                                      product['qty'].toString()),
                                  SizedBox(height: 10),
                                  _buildInfoRow(Icons.person_outlined,
                                      'Created By', product['createdBy']),
                                  SizedBox(height: 10),
                                  _buildInfoRow(Icons.person_outlined,
                                      'Updated By', product['updatedBy']),
                                  SizedBox(height: 10),
                                  _buildInfoRow(
                                      Icons.date_range_outlined,
                                      'Created At',
                                      _formatDate(product['createdAt'])),
                                  SizedBox(height: 10),
                                  _buildInfoRow(
                                      Icons.date_range_outlined,
                                      'Updated At',
                                      _formatDate(product['updatedAt'])),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
