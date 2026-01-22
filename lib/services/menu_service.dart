import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/menu_model.dart';

class MenuService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<MenuModel>> getMenus() async {
    final token = await _getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}menus"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MenuModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal load menu (${response.statusCode})");
    }
  }
}
