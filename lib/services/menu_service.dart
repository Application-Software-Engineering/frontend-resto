import 'dart:convert';
import 'package:http/http.dart' as http;
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
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else {
      throw Exception('Gagal ambil data menu: ${response.body}'); 
    }
  }
}