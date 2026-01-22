import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/menu_model.dart';

class MenuService {
  // Use localhost for web/desktop, 10.0.2.2 for Android emulator
  final String baseUrl = 'http://localhost:3000'; 
  final AuthService _authService = AuthService();

  Future<List<MenuModel>> getMenus() async {
    final token = await _authService.getToken();

    // Note: Assuming endpoint is /menus based on typical REST conventions and conflicts
    // If it fails, we might need to change to /menu
    final url = Uri.parse('$baseUrl/menus'); 
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MenuModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal ambil data menu: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteMenu(int id) async {
    final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/menus/$id');

    final response = await http.delete(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal hapus data menu: ${response.statusCode} - ${response.body}');
    }
  }
}
