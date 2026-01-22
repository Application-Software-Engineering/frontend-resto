import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
// Import AuthService agar token tidak hardcoded
import '../services/auth_service.dart'; 

class EditMenuPage extends StatefulWidget {
  final int id;
  final String nama;
  final int price;
  final int stock;
  final String imageUrl;

  const EditMenuPage({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  late TextEditingController namaController;
  late TextEditingController hargaController;
  late TextEditingController stokController;

  File? imageFile;
  XFile? webImage;
  bool loading = false;
  final AuthService _authService = AuthService();

  final String baseUrl =
      kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    hargaController = TextEditingController(text: widget.price.toString());
    stokController = TextEditingController(text: widget.stock.toString());
  }

  /// PICK IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        if (kIsWeb) {
          webImage = picked;
        } else {
          imageFile = File(picked.path);
        }
      });
    }
  }

  /// UPDATE MENU
  Future<void> updateMenu() async {
    setState(() => loading = true);

    try {
      // 1. Ambil token secara dinamis dari SharedPreferences
      final String? token = await _authService.getToken(); 

      final request = http.MultipartRequest(
        "PUT",
        Uri.parse("$baseUrl/menus/${widget.id}"),
      );

      // 2. Gunakan token terbaru di header
      if (token != null) {
        request.headers['Authorization'] = "Bearer $token";
      }

      // Pastikan nama field sesuai dengan backend (misal: 'name' atau 'nama')
      // 1. Pastikan nama field sesuai dengan Backend
      request.fields['name'] = namaController.text;   
      request.fields['price'] = hargaController.text;  
      request.fields['stock'] = stokController.text;    // Sebelumnya 'stock'

      /// jika user ganti gambar
      /// jika user ganti gambar
      if ((kIsWeb && webImage != null) || (!kIsWeb && imageFile != null)) {
        String subtype = "jpeg"; // Default
        
        if (kIsWeb) {
          final bytes = await webImage!.readAsBytes();
          final ext = webImage!.name.split('.').last.toLowerCase();
          if (ext == "png") subtype = "png";
          if (ext == "webp") subtype = "webp";

          request.files.add(
            http.MultipartFile.fromBytes(
              'image', // HARUS 'image' sesuai backend
              bytes,
              filename: webImage!.name,
              contentType: MediaType('image', subtype),
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image', // HARUS 'image' sesuai backend
              imageFile!.path,
            ),
          );
        }
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil diupdate"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        // Tampilkan pesan error dari server (misal: "Token invalid")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $responseData"), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// PREVIEW IMAGE
  Widget imagePreview() {
    if (kIsWeb && webImage != null) {
      return Image.network(webImage!.path, fit: BoxFit.cover, width: double.infinity);
    } else if (!kIsWeb && imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover, width: double.infinity);
    } else if (widget.imageUrl.isNotEmpty && widget.imageUrl.startsWith('http')) {
      // Pastikan URL valid agar tidak muncul ImageCodecException
      return Image.network(
        widget.imageUrl, 
        fit: BoxFit.cover, 
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50)),
      );
    } else {
      return const Center(child: Icon(Icons.image, size: 50, color: Colors.grey));
    }
  }

  Widget inputField(String label, TextEditingController controller, {bool number = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Menu"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            inputField("Nama menu", namaController),
            inputField("Price", hargaController, number: true),
            inputField("Stock", stokController, number: true),

            /// IMAGE AREA
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imagePreview(),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black54,
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : updateMenu,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Update", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}