import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/registrasi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistPage(),
      },
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: const RegistPage(),
      ),
    );
  }
}