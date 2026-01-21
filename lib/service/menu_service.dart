import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';

class MenuService {
  final String baseUrl = 'http://localhost:3000';

  Future<List<MenuModel>> fetchMenus() async {
    final url = Uri.parse('$baseUrl/menu');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
    
      return jsonList.map((item) => MenuModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal ambil data menu: ${response.statusCode}');
    }
  }
}