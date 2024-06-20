import 'package:flutter/material.dart';
import 'package:mobile/pages/category_page.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/pages/login_or_register.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/product_detail_page.dart';
import 'package:mobile/pages/register_page.dart';
import 'package:mobile/pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash':(context) => const SplashScreen(),
        '/login': (context) => LoginPage(onTap: () {
          Navigator.pushNamed(context, '/register');
        }),
        '/register': (context) => RegisterPage(onTap: () {
          Navigator.pushNamed(context, '/login');
        }),
        '/loginOrRegister': (context) => LoginOrRegisterPage(),
        '/home': (context) => HomePage(),
        '/categories': (context) => CategoryPage(),
        '/productDetail': (context) => ProductDetailPage(),
      },
    );
  }
}
