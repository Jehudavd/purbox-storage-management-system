import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({Key? key}) : super(key: key);

  @override
  _LoginOrRegisterPageState createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  // Function untuk toggle antara halaman login dan registrasi
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menampilkan halaman login jika showLoginPage bernilai true, 
    // dan halaman registrasi jika showLoginPage bernilai false
    return showLoginPage ? LoginPage(onTap: togglePages) : RegisterPage(onTap: togglePages);
  }
}
