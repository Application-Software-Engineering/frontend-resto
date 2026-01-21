import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class OrderService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> createOrder(List<Map<String, dynamic>> items) async {
    try {
      print('🛒 DEBUG - Creating order with ${items.length} items');
      print('🛒 DEBUG - Items: $items');
      
      final token = await _getToken();
      print('🔑 DEBUG - Token: ${token ?? "NULL - TIDAK ADA TOKEN!"}');
      
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}orders';
      print('🌐 DEBUG - URL: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'items': items}),
      );

      print('📥 DEBUG - Status Code: ${response.statusCode}');
      print('📥 DEBUG - Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ DEBUG - Order berhasil dibuat!');
        return {
          'success': true,
          'order_id': data['order_id'],
          'total': data['total'],
        };
      } else {
        print('❌ DEBUG - Gagal create order');
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat pesanan',
        };
      }
    } catch (e) {
      print('💥 DEBUG - Exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final token = await _getToken();
      print('🔑 DEBUG - Token: ${token ?? "NULL - TIDAK ADA TOKEN!"}');
      
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}orders';
      print('🌐 DEBUG - URL: $url');
      print('📨 DEBUG - Headers: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📥 DEBUG - Status Code: ${response.statusCode}');
      print('📥 DEBUG - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ DEBUG - Data berhasil di-parse: ${data.length} orders');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ DEBUG - Status code bukan 200');
        throw Exception('Status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 DEBUG - Exception: $e');
      rethrow;
    }
  }
}
