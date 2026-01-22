import 'package:flutter/material.dart';
import 'package:frontend_resto/models/menu_model.dart';
import 'package:frontend_resto/services/menu_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

const String imageBaseUrl = "http://localhost:3000";

class _DashboardPageState extends State<DashboardPage> {
  final MenuService _menuService = MenuService();
  late Future<List<MenuModel>> _futureMenus;

  @override
  void initState() {
    super.initState();
    _futureMenus = _menuService.getMenus();
  }

  /// === BOTTOM SHEET ===
  void _showAddToCartSheet(MenuModel item) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: item.image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  "$imageBaseUrl${item.image}",
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.food_bank,
                                size: 40,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            "Rp ${item.price}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            "Sisa Stok: ${item.stock}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Jumlah Pesanan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (quantity > 1) {
                                setModalState(() => quantity--);
                              }
                            },
                          ),
                          Text(
                            "$quantity",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setModalState(() => quantity++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "$quantity ${item.name} ditambahkan",
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text(
                        "Tambah ke Keranjang",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final PageController controller = PageController(
      viewportFraction: 0.8,
      initialPage: 1000,
    );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Selamat Datang!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          /// === CAROUSEL ===
          SizedBox(
            height: (screenSize.height * 0.25).clamp(180, 300),
            child: FutureBuilder<List<MenuModel>>(
              future: _futureMenus,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final menus = snapshot.data ?? [];

                if (menus.isEmpty) {
                  return const Center(child: Text("Belum ada menu"));
                }

                return PageView.builder(
                  controller: controller,
                  itemCount: menus.length,
                  itemBuilder: (_, index) {
                    final item = menus[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: item.image != null
                            ? Image.network(
                                "$imageBaseUrl${item.image}",
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 50),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          /// === MENU GRID ===
          FutureBuilder<List<MenuModel>>(
            future: _futureMenus,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final menus = snapshot.data ?? [];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menus.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (_, i) {
                  final item = menus[i];
                  return InkWell(
                    onTap: () => _showAddToCartSheet(item),
                    child: _menuCard(item),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuCard(MenuModel item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: item.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "$imageBaseUrl${item.image}",
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.food_bank, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          Text("Stok: ${item.stock}", style: const TextStyle(fontSize: 11)),
          Text(
            "Rp ${item.price}",
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
