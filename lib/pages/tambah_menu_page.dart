import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dashboard.dart';

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

  final String baseUrl =
      kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";

  final String token =
      "isi token";

  
  
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

  
  /// UPLOAD MENU

  Future<void> tambahMenu() async {
    if ((kIsWeb && webImage == null) || (!kIsWeb && imageFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar dulu")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final request =
          http.MultipartRequest("POST", Uri.parse("$baseUrl/menus"));

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil ditambahkan")),
        );

        /// reload data k3 dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (route) => false,
        );
      } else {
        final body = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body)),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  
  /// IMAGE PREVIEW
  
  Widget imagePreview() {
    if (kIsWeb && webImage != null) {
      return Image.network(webImage!.path, fit: BoxFit.cover);
    } else if (!kIsWeb && imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover);
    }
    return const Icon(Icons.add, size: 48, color: Colors.grey);
  }

  
  /// INPUT FIELD

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
          keyboardType:
              number ? TextInputType.number : TextInputType.text,
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

  
  /// UI
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
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
                            builder: (_) => const DashboardPage()),
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