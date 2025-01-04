import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Initialize secure storage
const secureStorage = FlutterSecureStorage();

// Base URL API
const String baseUrl = 'http://192.168.18.60:8000/api';

// Fungsi untuk mendapatkan header dengan token
Future<Map<String, String>> getHeadersWithToken() async {
  final accessToken = await secureStorage.read(key: 'access_token');
  return {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };
}

// Fungsi untuk menambahkan brand
Future<void> addBrand({
  required String name,
  required String description,
}) async {
  final url = Uri.parse('$baseUrl/brands');
  try {
    final headers = await getHeadersWithToken(); // Get headers with token

    final response = await http.post(
      url,
      headers: headers, // Add headers with Authorization
      body: json.encode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      print('Brand berhasil ditambahkan!');
    } else if (response.statusCode == 401) {
      throw Exception(
          'Gagal menambahkan brand: Token tidak valid atau kadaluarsa');
    } else {
      final error = json.decode(response.body);
      throw Exception('Gagal menambahkan brand: ${error['message']}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

// Fungsi untuk mengambil data brand
Future<List<dynamic>> fetchBrands() async {
  final url = Uri.parse('$baseUrl/brands');
  try {
    final headers = await getHeadersWithToken(); // Get headers with token

    final response = await http.get(
      url,
      headers: headers, // Add headers with Authorization
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Assuming the data is in the 'data' key
    } else if (response.statusCode == 401) {
      throw Exception(
          'Gagal mengambil data brand: Token tidak valid atau kadaluarsa');
    } else {
      final error = json.decode(response.body);
      throw Exception('Gagal mengambil data brand: ${error['message']}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

// Fungsi untuk mengupdate brand
Future<void> updateBrand({
  required int brandId,
  required String name,
  required String description,
}) async {
  final url = Uri.parse('$baseUrl/brands/$brandId');
  try {
    final headers = await getHeadersWithToken(); // Get headers with token

    final response = await http.put(
      url,
      headers: headers, // Add headers with Authorization
      body: json.encode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      print('Brand berhasil diperbarui!');
    } else if (response.statusCode == 401) {
      throw Exception(
          'Gagal mengupdate brand: Token tidak valid atau kadaluarsa');
    } else {
      final error = json.decode(response.body);
      throw Exception('Gagal mengupdate brand: ${error['message']}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

// Fungsi untuk menghapus brand
Future<void> deleteBrand(int brandId) async {
  final url = Uri.parse('$baseUrl/brands/$brandId');
  try {
    final headers = await getHeadersWithToken(); // Get headers with token

    final response = await http.delete(
      url,
      headers: headers, // Add headers with Authorization
    );

    if (response.statusCode == 200) {
      print('Brand berhasil dihapus!');
    } else if (response.statusCode == 401) {
      throw Exception(
          'Gagal menghapus brand: Token tidak valid atau kadaluarsa');
    } else {
      final error = json.decode(response.body);
      throw Exception('Gagal menghapus brand: ${error['message']}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
