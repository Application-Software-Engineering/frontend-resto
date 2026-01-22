import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_resto/models/menu_model.dart';
import 'package:frontend_resto/services/menu_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend_resto/providers/cart_provider.dart';
import 'edit_menu_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

const String imageBaseUrl = "http://localhost:3000";

class _DashboardPageState extends State<DashboardPage> {
  String _displayName = "User";
  // final AuthService _authService = AuthService(); // Removed unused field
  final MenuService _menuService = MenuService();
  late Future<List<MenuModel>> _futureMenus;

  @override
  void initState() {
    super.initState();
    _getSavedName();
    _futureMenus = _menuService.getMenus();
  }

  void _getSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('name') ?? "User";
    });
  }

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
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  "$imageBaseUrl${item.image}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.food_bank, size: 40, color: Colors.white),
                                ),
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
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rp ${item.price}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Sisa Stok: ${item.stock}",
                            style: GoogleFonts.poppins(
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
                      Text(
                        "Jumlah Pesanan",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
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
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setModalState(() => quantity++);
                              },
                            ),
                          ],
                        ),
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
                        Provider.of<CartProvider>(context, listen: false).addToCart(item, quantity);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "$quantity ${item.name} berhasil ditambahkan!",
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Tambah ke Keranjang",
                        style: GoogleFonts.poppins(
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
      viewportFraction: 0.6,
      initialPage: 1000,
    );

    return Scaffold(
      // AppBar removed to match original design
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "Selamat Datang!, $_displayName",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ================== CAROUSEL ==================
          SizedBox(
            height: (screenSize.height * 0.25).clamp(180.0, 300.0),
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
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, size: 50, color: Colors.grey),
                              )
                            : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          /// === MENU GRID ===
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List Menu',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
                child: Container(
                  width: double.infinity,
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
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.food_bank, size: 40, color: Colors.white),
                          ),
                        )
                      : const Center(child: Icon(Icons.food_bank, size: 40, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text("Stok: ${item.stock}", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              Text(
                "Rp ${item.price}",
                style: GoogleFonts.poppins(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  onPressed: () {
                    // Navigate to edit page
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMenuPage(
                            id: item.id ?? 0, 
                            name: item.name, 
                            price: item.price, 
                            stock: item.stock, 
                            imageUrl: item.image ?? '',
                          ),
                        ),
                      ).then((_) {
                        // Refresh menu after edit
                        setState(() {
                           _futureMenus = _menuService.getMenus();
                        });
                      });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_outlined, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Hapus Menu"),
                          content: Text("Apakah Anda yakin ingin menghapus '${item.name}'?"),
                          actions: [
                            TextButton(
                              child: const Text("Batal"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                try {
                                  await _menuService.deleteMenu(item.id ?? 0);
                                  if (mounted) {
                                    setState(() {
                                      _futureMenus = _menuService.getMenus();
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("'${item.name}' berhasil dihapus")),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Gagal menghapus: $e")),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}