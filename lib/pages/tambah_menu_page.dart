import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_resto/pages/main_page.dart'; // Changed import
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:frontend_resto/services/auth_service.dart';


class TambahMenuPage extends StatefulWidget {
  const TambahMenuPage({super.key});

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();

  File? imageFile;
  XFile? webImage;
  bool loading = false;
  final AuthService _authService = AuthService();

  // Assuming localhost for both or adjusted for Android 10.0.2.2 if needed but keeping it as per previous config
  String get _baseUrl => kIsWeb ? "http://localhost:3000" : "http://localhost:3000";

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

  Future<void> tambahMenu() async {
    if ((kIsWeb && webImage == null) || (!kIsWeb && imageFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar dulu")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final token = await _authService.getToken();
      if (token == null) {
          throw Exception("Token tidak ditemukan, silakan login ulang.");
      }

      final request =
          http.MultipartRequest("POST", Uri.parse("$_baseUrl/menus"));

      request.headers['Authorization'] = "Bearer $token";
      request.fields['name'] = namaController.text;
      request.fields['price'] = hargaController.text;
      request.fields['stock'] = stokController.text;

      if (kIsWeb) {
        final bytes = await webImage!.readAsBytes();
        final ext = webImage!.name.split('.').last.toLowerCase();

        String subtype = "jpeg";
        if (ext == "png") subtype = "png";
        if (ext == "gif") subtype = "gif";
        if (ext == "webp") subtype = "webp";

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: webImage!.name,
            contentType: MediaType('image', subtype),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil ditambahkan")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
          (route) => false,
        );
      } else {
        final body = await response.stream.bytesToString();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $body")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget imagePreview() {
    if (kIsWeb && webImage != null) {
      return FutureBuilder(
        future: webImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return Image.memory(
            snapshot.data as Uint8List,
            fit: BoxFit.cover,
          );
        },
      );
    } else if (!kIsWeb && imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover);
    }
    return const Icon(Icons.add, size: 48, color: Colors.grey);
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    bool number = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainPage()),
              (route) => false,
            );
          },
        ),
        title: const Text("Tambah Menu"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            inputField("Nama Menu", namaController),
            inputField("Price", hargaController, number: true),
            inputField("Stock", stokController, number: true),

            /// IMAGE PICKER
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey.shade100,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imagePreview(),
                    ),
                    if ((kIsWeb && webImage != null) ||
                        (!kIsWeb && imageFile != null))
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black54,
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// BUTTON
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MainPage()),
                        (route) => false,
                      );
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : tambahMenu,
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Add"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
