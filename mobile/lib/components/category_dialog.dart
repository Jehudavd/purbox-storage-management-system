import 'package:flutter/material.dart';

// Dialog untuk menambahkan atau mengedit kategori
class CategoryDialog extends StatelessWidget {
  final TextEditingController nameController; // Controller untuk input nama kategori
  final GlobalKey<FormState> formKey; // Key untuk form validasi
  final Function onSave; // Fungsi yang dipanggil saat menyimpan kategori

  const CategoryDialog({
    required this.nameController,
    required this.formKey,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'), // Judul dialog
      content: SingleChildScrollView(
        child: Form(
          key: formKey, // Key untuk form validasi
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input field untuk nama kategori
              CustomTextField(
                controller: nameController,
                icon: Icons.category,
                hintText: 'Category Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name'; // Validasi input tidak boleh kosong
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Tombol untuk membatalkan operasi
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Menutup dialog
          },
          child: const Text('Cancel'),
        ),
        // Tombol untuk menyimpan kategori
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              onSave(); // Memanggil fungsi onSave jika validasi berhasil
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Widget kustom untuk input field
class CustomTextField extends StatelessWidget {
  final TextEditingController controller; // Controller untuk mengontrol teks input
  final IconData icon; // Ikon yang ditampilkan di depan input field
  final String hintText; // Teks hint yang ditampilkan di input field
  final TextInputType keyboardType; // Jenis input
  final String? Function(String?)? validator; // Fungsi validasi

  const CustomTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Mengatur controller untuk input field
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple), // Menampilkan ikon di depan input field
        hintText: hintText, // Menampilkan hint text
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Sudut membulat pada border
          borderSide: BorderSide.none, // Tidak ada border
        ),
        filled: true, // Mengaktifkan warna latar belakang
        fillColor: Colors.white, // Warna latar belakang input field
      ),
      keyboardType: keyboardType, // Jenis input (default adalah teks)
      validator: validator, // Fungsi validasi input
    );
  }
}
