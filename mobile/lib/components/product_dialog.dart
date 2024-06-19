import 'package:flutter/material.dart';

// Dialog untuk menambahkan atau mengedit produk
class ProductDialog extends StatelessWidget {
  final TextEditingController nameController; // Controller untuk input nama produk
  final TextEditingController qtyController; // Controller untuk input jumlah produk
  final TextEditingController urlController; // Controller untuk input URL gambar produk
  final String? selectedCategoryId; // ID kategori yang dipilih
  final List categories; // Daftar kategori yang tersedia
  final GlobalKey<FormState> formKey; // Key untuk form validasi
  final Function onSave; // Fungsi yang dipanggil saat menyimpan produk
  final Function(String?) onCategoryChanged; // Fungsi yang dipanggil saat kategori berubah

  const ProductDialog({
    required this.nameController,
    required this.qtyController,
    required this.urlController,
    required this.selectedCategoryId,
    required this.categories,
    required this.formKey,
    required this.onSave,
    required this.onCategoryChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        selectedCategoryId == null ? 'Add Product' : 'Edit Product', // Judul dialog
        style: const TextStyle(color: Colors.deepPurple),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey, // Key untuk form validasi
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input field untuk nama produk
              CustomTextField(
                controller: nameController,
                icon: Icons.shopping_bag_outlined,
                hintText: 'Product Name',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a product name' : null,
              ),
              const SizedBox(height: 16),
              // Input field untuk jumlah produk
              CustomTextField(
                controller: qtyController,
                icon: Icons.inventory_outlined,
                hintText: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter the quantity';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown untuk memilih kategori produk
              CustomDropdown(
                selectedCategoryId: selectedCategoryId,
                categories: categories,
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: 16),
              // Input field untuk URL gambar produk
              CustomTextField(
                controller: urlController,
                icon: Icons.image_outlined,
                hintText: 'Image URL',
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Tombol untuk membatalkan operasi
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple)),
        ),
        // Tombol untuk menyimpan perubahan atau menambahkan produk baru
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple, // Mengganti primary dengan backgroundColor
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              onSave(); // Memanggil fungsi onSave jika validasi berhasil
            }
          },
          child: Text(
            selectedCategoryId == null ? 'Add' : 'Update',
            style: const TextStyle(color: Colors.white), // Warna teks diatur menjadi putih
          ),
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
        hintStyle: const TextStyle(color: Colors.grey), // Warna hint text
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Sudut membulat pada border
          borderSide: const BorderSide(color: Colors.deepPurple, width: 1), // Warna border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Sudut membulat pada border
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2), // Warna border saat fokus
        ),
        filled: true, // Mengaktifkan warna latar belakang
        fillColor: Colors.grey[100], // Warna latar belakang input field
      ),
      keyboardType: keyboardType, // Jenis input (default adalah teks)
      validator: validator, // Fungsi validasi input
    );
  }
}

// Widget kustom untuk dropdown kategori
class CustomDropdown extends StatelessWidget {
  final String? selectedCategoryId; // ID kategori yang dipilih
  final List categories; // Daftar kategori yang tersedia
  final Function(String?) onChanged; // Fungsi yang dipanggil saat kategori berubah

  const CustomDropdown({
    required this.selectedCategoryId,
    required this.categories,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.deepPurple), // Menampilkan ikon di depan dropdown
        hintText: 'Category', // Menampilkan hint text
        hintStyle: const TextStyle(color: Colors.grey), // Warna hint text
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Sudut membulat pada border
          borderSide: const BorderSide(color: Colors.deepPurple, width: 1), // Warna border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Sudut membulat pada border
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2), // Warna border saat fokus
        ),
        filled: true, // Mengaktifkan warna latar belakang
        fillColor: Colors.grey[100], // Warna latar belakang dropdown
      ),
      value: selectedCategoryId, // Nilai yang dipilih
      items: categories.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem<String>(
          value: category['id'].toString(),
          child: Text(category['name']), // Nama kategori yang ditampilkan di dropdown
        );
      }).toList(),
      onChanged: onChanged, // Fungsi yang dipanggil saat kategori berubah
      validator: (value) => value == null ? 'Please select a category' : null, // Validasi dropdown
    );
  }
}
