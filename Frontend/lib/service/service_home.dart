import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const secureStorage = FlutterSecureStorage();
const String baseUrl = 'http://172.20.10.2:8000/api';

// Fungsi untuk mendapatkan header default, termasuk Authorization jika token tersedia
Future<Map<String, String>> getDefaultHeaders() async {
  final accessToken = await secureStorage.read(key: 'access_token');
  return {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };
}

class ShoesService {
  Future<List<Map<String, dynamic>>> fetchShoes() async {
    final url = Uri.parse('$baseUrl/shoes');

    try {
      final headers = await getDefaultHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load shoes: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching shoes: $e');
    }
  }
}
