import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();
const String baseUrl = 'http://172.20.10.2:8000/api';

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
  final url = Uri.parse("http://172.0.0.2:8000/api/register");

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
      // Optionally log in after registration
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

// Logout and delete token from secure storage
Future<void> logout() async {
  await secureStorage.delete(key: 'access_token');
  print('Access token successfully deleted.');
}

// Delete user account
Future<void> deleteUserAccount() async {
  try {
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception('No access token found. Please log in again.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/user/delete'), // Update with correct API endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await secureStorage.delete(key: 'access_token');
      print('User account successfully deleted.');
    } else {
      final error = json.decode(response.body);
      throw Exception(
          'Failed to delete user: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    throw Exception('An error occurred: $e');
  }
}
