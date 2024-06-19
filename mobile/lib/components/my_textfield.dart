// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

// Widget kustom untuk input field dengan opsi untuk menyembunyikan teks (misalnya untuk password)
class MyTextField extends StatefulWidget {
  final TextEditingController controller; // Controller untuk mengontrol teks input
  final String hintText; // Teks hint yang ditampilkan di input field
  final bool obscureText; // Menentukan apakah teks harus disembunyikan

  const MyTextField({super.key, required this.controller, required this.hintText, required this.obscureText});

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText; // Variabel untuk menyimpan status penyembunyian teks

  @override
  void initState() {
    super.initState();
    // Inisialisasi status penyembunyian teks berdasarkan nilai yang diberikan dari widget
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25), // Padding horizontal untuk input field
      child: TextField(
        controller: widget.controller, // Mengatur controller untuk input field
        obscureText: _obscureText, // Mengatur apakah teks disembunyikan atau tidak
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)), // Border ketika input field tidak fokus
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)), // Border ketika input field fokus
          fillColor: Colors.grey.shade200, // Warna latar belakang input field
          filled: true, // Mengaktifkan warna latar belakang
          hintText: widget.hintText, // Menampilkan hint text
          hintStyle: TextStyle(color: Colors.grey[500]), // Warna hint text
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility), // Ikon untuk menunjukkan status penyembunyian teks
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Toggle status penyembunyian teks
                    });
                  },
                )
              : null, // Menampilkan ikon hanya jika teks disembunyikan
        ),
      ),
    );
  }
}
