import 'package:flutter/material.dart';

// Widget kustom untuk tombol
class MyButton extends StatelessWidget {
  final Function()? onTap; // Fungsi yang dipanggil saat tombol ditekan
  final String text; // Teks yang ditampilkan pada tombol

  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Menentukan aksi yang dilakukan saat tombol ditekan
      child: Container(
        padding: const EdgeInsets.all(25), 
        margin: const EdgeInsets.symmetric(horizontal: 25), 
        decoration: BoxDecoration(
          color: Colors.deepPurple, 
          borderRadius: BorderRadius.circular(8), 
        ),
        child: Center(
          child: Text(
            text, 
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 16, 
            ),
          ),
        ),
      ),
    );
  }
}
