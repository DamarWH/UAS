import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShoeDetailScreen extends StatefulWidget {
  final int shoeId;
  const ShoeDetailScreen({Key? key, required this.shoeId}) : super(key: key);

  @override
  State<ShoeDetailScreen> createState() => _ShoeDetailScreenState();
}

class _ShoeDetailScreenState extends State<ShoeDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _shoeDetails;

  @override
  void initState() {
    super.initState();
    _fetchShoeDetails();
  }

  // Fetch shoe details by ID
  Future<void> _fetchShoeDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.0.0.2:8000/api/shoes/${widget.shoeId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _shoeDetails = data['data'];
        });
      } else {
        throw Exception('Failed to load shoe details');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoe Details'),
        backgroundColor: const Color.fromRGBO(215, 163, 67, 1),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shoeDetails == null
              ? const Center(child: Text('No details available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        _shoeDetails!['shoe']['imageUrls'][0] ??
                            'https://via.placeholder.com/150',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _shoeDetails!['shoe']['model_name'] ?? 'Unknown Model',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Brand: ${_shoeDetails!['brand']['brand_name'] ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Price: Rp ${_shoeDetails!['shoe']['harga']}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _shoeDetails!['shoe']['description'] ??
                            'No description available.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}
