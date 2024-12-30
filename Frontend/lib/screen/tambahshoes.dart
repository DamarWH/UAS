import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'http://172.20.10.2:8000/api';

class AddShoesScreen extends StatefulWidget {
  const AddShoesScreen({super.key});

  @override
  State<AddShoesScreen> createState() => _AddShoesScreenState();
}

class _AddShoesScreenState extends State<AddShoesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sepatuTypeController = TextEditingController();
  final TextEditingController _modelNameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _warnaController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _manualUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _brandIdController = TextEditingController();

  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken(); // Load token when the screen is initialized
  }

  // Fetch the stored token
  Future<void> _loadToken() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    setState(() {
      _token = token;
    });
  }

  // Check if user is authenticated
  Future<bool> _isAuthenticated() async {
    if (_token == null || _token!.isEmpty) {
      return false;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/shoes'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Submit the form to add shoes
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if the user is authenticated
      bool isAuthenticated = await _isAuthenticated();

      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anda perlu login terlebih dahulu.")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _addShoes(
          token: _token!,
          brandId: int.tryParse(_brandIdController.text),
          sepatuType: _sepatuTypeController.text,
          modelName: _modelNameController.text,
          size: int.parse(_sizeController.text),
          harga: int.parse(_hargaController.text),
          warna: _warnaController.text,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
          manualUrl: _manualUrlController.text.isNotEmpty
              ? _manualUrlController.text
              : null,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sepatu berhasil ditambahkan!")),
        );

        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan sepatu: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // API call to add shoes
  Future<void> _addShoes({
    required String token,
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
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
      } else {
        final error = json.decode(response.body);
        throw Exception(
            'Gagal menambahkan sepatu: ${error['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Sepatu'),
        backgroundColor: const Color.fromARGB(255, 215, 163, 67),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brandIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Brand ID (1 = Nike, 2=Adidas, 3=Puma)',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan ID Brand, contoh: 1, 2, 3...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Brand ID harus diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Brand ID harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sepatuTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipe Sepatu',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tipe sepatu harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Model',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama model harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ukuran',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ukuran harus diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Ukuran harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga harus diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _warnaController,
                  decoration: const InputDecoration(
                    labelText: 'Warna',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Warna harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Gambar (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _manualUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Manual (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 215, 163, 67),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tambah Sepatu',
                          style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
