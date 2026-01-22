import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_resto/pages/login.dart';
import 'package:http/http.dart' as http;

class RegistPage extends StatefulWidget {
  const RegistPage({super.key});

  @override
  State<RegistPage> createState() => _RegistPageState();
}

class _RegistPageState extends State<RegistPage> {
  bool _showpassword = true;
  bool _showpassword2 = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Future<void> handleRegist() async {
  //   if (emailController.text.isEmpty ||
  //       usernameController.text.isEmpty ||
  //       passwordController.text.isEmpty ||
  //       confirmPasswordController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Jangan ada yang kosong ya isinya!'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  //   if (passwordController.text != confirmPasswordController.text) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Password dan Confirm Password harus sama!'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   final url = Uri.parse('http://localhost:3000/auth/register');
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: {
  //         'name': usernameController.text,
  //         'email': emailController.text,
  //         'password': passwordController.text,
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       Navigator.pop(context);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Registrasi gagal. Silakan coba lagi.'),
  //           backgroundColor: Colors.red,
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Terjadi kesalahan. Silakan coba lagi.'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  Future<void> handleRegist() async {
    // 1. Log validasi awal
    print("--- Memulai Proses Registrasi ---");
    
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      print("Error: Ada field yang kosong.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jangan ada yang kosong ya isinya!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Berhenti di sini
    }

    if (passwordController.text != confirmPasswordController.text) {
      print("Error: Password dan Confirm Password tidak sinkron.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password dan Confirm Password harus sama!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Berhenti di sini
    }

    // Ganti localhost ke 10.0.2.2 jika pakai emulator Android bawaan
    final url = Uri.parse('http://localhost:3000/auth/register');
    
    print("Mencoba request ke: $url");
    print("Data yang dikirim: {name: ${usernameController.text}, email: ${emailController.text}}");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'name': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        },
      ));

      // 2. Log detail response dari server
      print("Status Code Server: ${response.statusCode}");
      print("Body Response: ${response.body}");

      if (response.statusCode == 200) {
        print("Registrasi Berhasil!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi Sukses! Silakan Login'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        print("Registrasi Ditolak Server: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 3. Log error koneksi/sistem
      print("CRITICAL ERROR (Exception): $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak bisa terhubung ke server. Cek koneksi/IP!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fastfood,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'OCONFOOD',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Selamat Datang di OCONFOOD!',
                  style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  height: 450,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Masukkan email Anda',
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: 'Masukkan username Anda',
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            controller: passwordController,
                            obscureText: _showpassword,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showpassword = !_showpassword;
                                  });
                                }, 
                                icon: Icon(
                                    _showpassword ? Icons.remove_red_eye : Icons. visibility_off,
                                  ),
                                ),
                              hintText: 'Masukkan password Anda',
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            controller: confirmPasswordController,
                            obscureText: _showpassword2,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showpassword2 = !_showpassword2;
                                  });
                                }, 
                                icon: Icon(
                                    _showpassword2 ? Icons.remove_red_eye : Icons. visibility_off,
                                  ),
                              ),
                              hintText: 'Konfirmasi password Anda',
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              handleRegist();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Colors.orange,
                          ),
                          child: Text(
                            'Registrasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Sudah punya akun? ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Login now",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
