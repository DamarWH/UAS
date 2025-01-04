import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Initialize secure storage
const secureStorage = FlutterSecureStorage();

// Base URL API
const String baseUrl = 'http:/192.168.18.60:8000/api';

// Fungsi untuk mendapatkan header dengan token
Future<Map<String, String>> getHeadersWithToken() async {
  final accessToken = await secureStorage.read(key: 'access_token');
  return {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };
}

// Fungsi untuk menambahkan data sepatu
Future<void> addShoes({
  int? brandId,
  required String sepatuType,
  required String modelName,
  required int size,
  required int harga,
  required String warna,
  String? imageUrl,
  String? manualUrl,
  String? description,
}) async {
  final url = Uri.parse('$baseUrl/shoes');
  try {
    final headers = await getHeadersWithToken(); // Get headers with token

    final response = await http.post(
      url,
      headers: headers, // Add headers with Authorization
      body: json.encode({
        'brand_id': brandId,
        'sepatu_type': sepatuType,
        'model_name': modelName,
        'size': size,
        'harga': harga,
        'warna': warna,
        'image_url': imageUrl,
        'manual_url': manualUrl,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      print('Sepatu berhasil ditambahkan!');
    } else if (response.statusCode == 401) {
      throw Exception(
          'Gagal menambahkan sepatu: Token tidak valid atau kadaluarsa');
    } else {
      final error = json.decode(response.body);
      throw Exception('Gagal menambahkan sepatu: ${error['message']}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
