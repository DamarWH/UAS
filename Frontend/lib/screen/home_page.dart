import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screen/tambahshoes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:frontend/screen/profile.dart';
import 'package:frontend/service/Service_Shoes.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> products = [];
  String username = "";

  @override
  void initState() {
    super.initState();
    _fetchShoes();
    _fetchUsername();
  }

  // Fetch shoes data
  void _fetchShoes() async {
    try {
      final shoes = await ShoesService().fetchShoes();
      if (shoes != null) {
        setState(() {
          products.clear(); // Clear existing data before adding updated data
          products.addAll(shoes);
        });
      } else {
        print("No shoes data available");
      }
    } catch (e) {
      print('Failed to load shoes: $e');
    }
  }

  // Fetch username from secure storage or API
  void _fetchUsername() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'access_token');
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('http://your-api-url/api/user/id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          username = data['name'] ?? "Guest";
        });
      }
    }
  }

  Future<void> _showEditDialog(int index) async {
    final product = products[index];
    final TextEditingController typeController =
        TextEditingController(text: product['sepatu_type']);
    final TextEditingController nameController =
        TextEditingController(text: product['model_name']);
    final TextEditingController sizeController =
        TextEditingController(text: product['size'].toString());
    final TextEditingController priceController =
        TextEditingController(text: product['harga'].toString());
    final TextEditingController colorController =
        TextEditingController(text: product['warna']);
    final TextEditingController descriptionController =
        TextEditingController(text: product['description'] ?? '');
    final TextEditingController brandController = TextEditingController(
        text: product['brand_id'].toString()); // Add brand_id controller

    final updatedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Tipe Sepatu'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Model'),
                ),
                TextField(
                  controller: sizeController,
                  decoration: const InputDecoration(labelText: 'Ukuran'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(labelText: 'Warna'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                ),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(
                      labelText: 'ID Brand'), // Add input for brand_id
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'shoes_id': product['shoes_id'],
                  'sepatu_type': typeController.text,
                  'model_name': nameController.text,
                  'size': int.tryParse(sizeController.text) ?? 0,
                  'harga': double.tryParse(priceController.text) ?? 0.0,
                  'warna': colorController.text,
                  'description': descriptionController.text,
                  'brand_id': int.tryParse(brandController.text) ??
                      0, // Include brand_id
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (updatedData != null) {
      _updateProduct(index, updatedData);
    }
  }

  void _updateProduct(int index, Map<String, dynamic> updatedData) async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'access_token');

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access token is missing or expired')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
            'http://192.168.18.60:8000/api/shoes/update/${updatedData['shoes_id']}'), // Ganti 'shoes_id' dengan 'id'
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil diperbarui')),
        );
        _fetchShoes(); // Refresh the list after update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal memperbarui produk: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to delete product
  void _deleteProduct(int index) async {
    final product = products[index];
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'access_token');

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access token is missing or expired')),
      );
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(
            'http://192.168.18.60:8000/api/shoes/delete/${product['shoes_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil dihapus')),
        );
        setState(() {
          products.removeAt(index); // Remove the product from the list
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal menghapus produk: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget buildProductCard(int index) {
    final product = products[index];
    final imageUrl = product['image_url'] ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 150,
            width: 150,
            alignment: Alignment.center,
            child: ExtendedImage.network(
              imageUrl,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
              cache: true,
              loadStateChanged: (ExtendedImageState state) {
                if (state.extendedImageLoadState == LoadState.failed) {
                  return const Icon(Icons.image_not_supported, size: 150);
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product['model_name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Rp ${product['harga']}',
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteProduct(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 163, 67),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(215, 163, 67, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.isNotEmpty ? 'Hai, $username' : 'Hai, Guest',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Widget Grid View",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.black),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: GridView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return buildProductCard(index);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Widget List View",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.black),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return buildProductCard(index);
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 16);
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddShoesScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
