import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pages/tambah_menu_page.dart';
import 'pages/edit_menu_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final String baseUrl =
      kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// SAMA SEPERTI PUNYAMU
      initialRoute: '/edit',

      routes: {
        '/add': (context) => const TambahMenuPage(),

        /// TEST EDIT TANPA LIST
        '/edit': (context) => EditMenuPage(
              id: 5, 
              nama: "ayam suwir",
              price: 20000,
              stock: 2,
              imageUrl: "$baseUrl/uploads/menus/logo.png",
            ),
      },
    );
  }
}
