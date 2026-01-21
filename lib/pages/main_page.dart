import 'package:flutter/material.dart';
import 'package:frontend_resto/pages/cart_page.dart';
import 'package:frontend_resto/pages/dashboard.dart';
import 'package:frontend_resto/pages/history_page.dart';
import 'package:frontend_resto/pages/tambah_menu_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const TambahMenuPage(),
    const HistoryPage(),                              // Index 2
  ];

  final List<String> _titles = [
    'Menu Favorit',
    'Tambah Menu Baru',
    'Riwayat Pesanan',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFEB204),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFFFEB204), // Warna Kuning Tema
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 28),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '2', // Variable jumlah item
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFEB204),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}