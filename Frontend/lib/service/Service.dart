import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();
const String baseUrl = 'http://192.168.18.60:8000/api';

// Function to get default headers, including Authorization if token is available
Future<Map<String, String>> getDefaultHeaders() async {
  final accessToken = await secureStorage.read(key: 'access_token');
  return {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };
}

// Login function
Future<void> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/auth/login');

  try {
    final response = await http.post(
      url,
      headers: await getDefaultHeaders(),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final accessToken = data['token']['access_token'];

      await secureStorage.write(key: 'access_token', value: accessToken);
      print('Access token successfully stored!');
    } else {
      final error = json.decode(response.body) as Map<String, dynamic>;
      throw Exception('Login failed: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

// Register function
Future<void> register(
    String name, String email, String password, String confirmPassword) async {
  final url = Uri.parse("$baseUrl/api/register");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": confirmPassword,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      print("Pendaftaran berhasil: ${data['message']}");
      await login(email, password);
    } else {
      final error = json.decode(response.body);
      throw Exception(
          "Pendaftaran gagal: ${error['message'] ?? 'Kesalahan server'}");
    }
  } catch (e) {
    throw Exception("Pendaftaran: $e");
  }
}

Future<void> delete() async {
  try {
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception('No access token found. Please log in again.');
    }

    // Mendapatkan ID pengguna dari API jika diperlukan
    final response = await http.get(
      Uri.parse(
          '$baseUrl/user/profile'), // Memastikan untuk mendapatkan ID pengguna
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userId = data['id']; // Ambil ID pengguna dari respons

      // Kirim permintaan DELETE dengan ID pengguna
      final deleteResponse = await http.delete(
        Uri.parse(
            '$baseUrl/user/delete/$userId'), // Kirim ID pengguna untuk dihapus
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (deleteResponse.statusCode == 200) {
        // Menghapus token setelah penghapusan berhasil
        await secureStorage.delete(key: 'access_token');
        print('User account successfully deleted.');
      } else {
        final error = json.decode(deleteResponse.body);
        throw Exception(
            'Failed to delete user: ${error['message'] ?? 'Server error'}');
      }
    } else {
      throw Exception('Failed to fetch user data: ${response.body}');
    }
  } catch (e) {
    throw Exception('An error occurred: $e');
  }

// Logout and delete token from secure storage
  Future<void> logout() async {
    await secureStorage.delete(key: 'access_token');
    print('Access token successfully deleted.');
  }
}
