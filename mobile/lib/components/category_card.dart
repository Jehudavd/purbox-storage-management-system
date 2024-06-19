import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final Map category; // Data kategori yang akan ditampilkan
  final Function(int) onDelete; // Fungsi yang dipanggil saat kategori dihapus

  const CategoryCard({
    required this.category,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Navigasi ke detail kategori saat kartu ditekan
      onTap: () => Navigator.pushNamed(
        context,
        '/categoryDetail',
        arguments: {'categoryId': category['id']},
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
            category['name'], // Nama kategori
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Teks tebal
              fontSize: 18, // Ukuran teks
              color: Colors.deepPurple, // Warna teks
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.deepPurple), // Ikon hapus
            onPressed: () async {
              // Menampilkan dialog konfirmasi hapus
              final confirmed = await _showDeleteConfirmationDialog(context);
              if (confirmed) {
                onDelete(category['id']);
              }
            },
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
        content: const Text('Are you sure you want to delete this category?'), // Konten dialog
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
