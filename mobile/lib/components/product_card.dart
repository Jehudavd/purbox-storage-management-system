import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product; // Data produk yang akan ditampilkan
  final String categoryName; // Nama kategori produk
  final String token; // Token untuk otentikasi
  final VoidCallback onDelete; // Fungsi yang dipanggil saat produk dihapus
  final VoidCallback onEdit; // Fungsi yang dipanggil saat produk diedit

  const ProductCard({
    required this.product,
    required this.categoryName,
    required this.token,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? 'No Name'; // Nama produk, default 'No Name' jika null
    final qty = product['qty']?.toString() ?? 'N/A'; // Jumlah produk, default 'N/A' jika null

    return GestureDetector(
      // Navigasi ke detail produk saat kartu ditekan
      onTap: () => Navigator.pushNamed(
        context,
        '/productDetail',
        arguments: {'productId': product['id'], 'token': token},
      ),
      child: Card(
        // Margin di sekitar kartu
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        // Bentuk kartu dengan sudut yang membulat
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3, // Bayangan kartu
        child: ListTile(
          contentPadding: const EdgeInsets.all(16), // Padding di dalam kartu
          title: Text(
            name, // Nama produk
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Teks tebal
              fontSize: 18, // Ukuran teks
              color: Colors.deepPurple, // Warna teks
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              // Menampilkan jumlah produk
              Text(
                'Qty: $qty',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 5),
              // Menampilkan kategori produk
              Text(
                'Category: $categoryName',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol edit produk
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.deepPurple),
                onPressed: onEdit,
              ),
              // Tombol hapus produk
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.deepPurple),
                onPressed: () async {
                  // Menampilkan dialog konfirmasi hapus
                  final confirmed = await _showDeleteConfirmationDialog(context);
                  if (confirmed) {
                    onDelete();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'), // Judul dialog
        content: const Text('Are you sure you want to delete this product?'), // Konten dialog
        actions: [
          // Tombol batal
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          // Tombol hapus
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
}
