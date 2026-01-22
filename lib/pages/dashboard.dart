import 'package:flutter/material.dart';
import 'package:frontend_resto/models/menu_model.dart';
import 'package:frontend_resto/services/menu_service.dart';
// import 'package:frontend_resto/models/cart_model.dart';

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

  // ================== BOTTOM SHEET ==================
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: item.image != null
                            ? Image.network(
                                "$imageBaseUrl${item.image}",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.green,
                                child: const Icon(
                                  Icons.food_bank,
                                  color: Colors.white,
                                  size: 40,
                                ),
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
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Stok: ${item.stock}",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Jumlah Pesanan",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                          Text("$quantity"),
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
                  const SizedBox(height: 15),
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
                              "${item.name} ditambahkan ke keranjang",
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Tambah ke Keranjang",
                        style: TextStyle(color: Colors.white),
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

  // ================== DELETE ==================
  void _confirmDelete(MenuModel item) {
    if (item.id == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Menu"),
        content: Text("Yakin hapus ${item.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _menuService.deleteMenu(item.id!);
              setState(() {
                _futureMenus = _menuService.getMenus();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Menu berhasil dihapus"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
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

          // ================== CAROUSEL ==================
          SizedBox(
            height: 220,
            child: FutureBuilder<List<MenuModel>>(
              future: _futureMenus,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final menus = snapshot.data!;
                return PageView.builder(
                  controller: controller,
                  itemBuilder: (_, index) {
                    final item = menus[index % menus.length];

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

          // ================== GRID MENU ==================
          FutureBuilder<List<MenuModel>>(
            future: _futureMenus,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final menus = snapshot.data!;
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

  // ================== MENU CARD ==================
  Widget _menuCard(MenuModel item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.image != null
                      ? Image.network(
                          "$imageBaseUrl${item.image}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          color: Colors.green,
                          child: const Icon(
                            Icons.food_bank,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () => _confirmDelete(item),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
