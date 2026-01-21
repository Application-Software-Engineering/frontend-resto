import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EditMenuPage extends StatefulWidget {
  final int id;
  final String nama;
  final int price;
  final int stock;
  final String imageUrl;

  const EditMenuPage({
    super.key,
    required this.id,
    required this.nama,
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

  final String baseUrl =
      kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";

  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiZW1haWwiOiJmYWl6YWxAbWFpbC5jb20iLCJpYXQiOjE3Njg4ODQyNzYsImV4cCI6MTc2ODg4Nzg3Nn0.lvJ7udpGaUYJrUS-CRHVn9D_L-5B49W6ds4NuAnw2zk";

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    hargaController =
        TextEditingController(text: widget.price.toString());
    stokController =
        TextEditingController(text: widget.stock.toString());
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
      final request = http.MultipartRequest(
        "PUT",
        Uri.parse("$baseUrl/menus/${widget.id}"),
      );

      request.headers['Authorization'] = "Bearer $token";

      request.fields['name'] = namaController.text;
      request.fields['price'] = hargaController.text;
      request.fields['stock'] = stokController.text;

      /// jika user ganti gambar
      if ((kIsWeb && webImage != null) ||
          (!kIsWeb && imageFile != null)) {
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
            await http.MultipartFile.fromPath(
              'image',
              imageFile!.path,
            ),
          );
        }
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil diupdate")),
        );
        Navigator.pop(context, true);
      } else {
        final body = await response.stream.bytesToString();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(body)));
      }
    } finally {
      setState(() => loading = false);
    }
  }

  /// PREVIEW IMAGE
  Widget imagePreview() {
    if (kIsWeb && webImage != null) {
      return Image.network(webImage!.path, fit: BoxFit.cover);
    } else if (!kIsWeb && imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover);
    } else {
      return Image.network(widget.imageUrl, fit: BoxFit.cover);
    }
  }

  Widget inputField(String label, TextEditingController controller,
      {bool number = false}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Update Menu"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            inputField("Nama menu", namaController),
            inputField("Price", hargaController, number: true),
            inputField("Stock", stokController, number: true),

            /// IMAGE
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
                        child: const Icon(Icons.edit,
                            size: 16, color: Colors.white),
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
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Update"),
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
