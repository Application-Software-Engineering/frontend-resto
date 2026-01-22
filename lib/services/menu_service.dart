import 'dart:convert';
import 'package:http/http.dart' as http;
<<<<<<< HEAD
import 'auth_service.dart'; 

class MenuService {
  final String baseUrl = 'http://localhost:3000';
  final AuthService _authService = AuthService();

  Future<List<Map<String, dynamic>>> fetchMenus() async {
  final url = Uri.parse('$baseUrl/menu');
  
  // 1. Ambil token dari memori HP
    final token = await _authService.getToken(); 
    
    print("🔑 DEBUG - Token di Service: $token");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',

        if (token != null) 'Authorization': 'Bearer $token',
=======
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
>>>>>>> 3cc082a1aa19628a08dfa242d260f3a3a7782015
      },
    );

    if (response.statusCode == 200) {
<<<<<<< HEAD
      List<dynamic> jsonList = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else {
      throw Exception('Gagal ambil data menu: ${response.body}'); 
=======
      final List data = jsonDecode(response.body);
      return data.map((e) => MenuModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal load menu (${response.statusCode})");
>>>>>>> 3cc082a1aa19628a08dfa242d260f3a3a7782015
    }
  }
}
