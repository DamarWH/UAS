import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const secureStorage = FlutterSecureStorage();
const String baseUrl = 'http://192.168.18.60:8000/api';

// Function to safely parse size and price fields
int parseIntOrZero(String value) {
  if (value.isEmpty) {
    return 0; // Default value if the field is empty
  }
  final parsedValue = int.tryParse(value);
  return parsedValue ?? 0; // If parsing fails, return 0
}

// Function to get default headers, including Authorization if token is available
Future<Map<String, String>> getDefaultHeaders() async {
  final accessToken = await secureStorage.read(key: 'access_token');
  return {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };
}

class ShoesService {
  // Fetch all shoes data
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

  // Fetch a specific shoe by ID
  Future<Map<String, dynamic>> fetchShoeById(int shoeId) async {
    final url = Uri.parse('$baseUrl/shoes/$shoeId');

    try {
      final headers = await getDefaultHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      } else {
        throw Exception('Failed to load shoe: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching the shoe: $e');
    }
  }

  // Create a new shoe
  Future<void> createShoe(Map<String, dynamic> newShoe) async {
    final url = Uri.parse('$baseUrl/shoes');

    try {
      final headers = await getDefaultHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(newShoe),
      );

      if (response.statusCode == 201) {
        print('Shoe created successfully');
      } else {
        throw Exception('Failed to create shoe: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating the shoe: $e');
    }
  }

  // Update an existing shoe
  Future<void> updateShoe(int shoeId, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('$baseUrl/shoes/$shoeId');

    try {
      final headers = await getDefaultHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Shoe updated successfully');
      } else {
        throw Exception('Failed to update shoe: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while updating the shoe: $e');
    }
  }

  // Delete a shoe by ID
  Future<void> deleteShoe(int shoeId) async {
    final url = Uri.parse('$baseUrl/shoes/$shoeId');

    try {
      final headers = await getDefaultHeaders();
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        print('Shoe deleted successfully');
      } else {
        throw Exception('Failed to delete shoe: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting the shoe: $e');
    }
  }
}
