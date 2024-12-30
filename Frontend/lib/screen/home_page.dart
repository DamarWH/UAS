import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screen/tambahshoes.dart';
import 'package:frontend/service/service_home.dart';
import 'package:extended_image/extended_image.dart';
import 'package:frontend/screen/profile.dart';
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

  // Ambil data sepatu dari backend
  void _fetchShoes() async {
    try {
      final shoes = await ShoesService().fetchShoes();
      if (shoes != null) {
        setState(() {
          products.addAll(shoes);
        });
      } else {
        print("No shoes data available");
      }
    } catch (e) {
      print('Failed to load shoes: $e');
    }
  }

  // Ambil nama pengguna dari secure storage atau API
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

  // Membuat kartu produk untuk digunakan kembali di GridView dan ListView
  Widget buildProductCard(int index) {
    final product = products[index];
    final imageUrl =
        product['image_url'] ?? ''; // Default fallback image jika null

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan konten
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
                return null; // Tampilkan gambar seperti biasa jika berhasil dimuat
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
              child:
                  CircularProgressIndicator(), // Menampilkan loading saat mengambil data
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.isNotEmpty
                          ? 'Hai, $username'
                          : 'Hai, Guest', // Menampilkan sapaan dengan nama pengguna
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
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
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
                          return buildProductCard(
                              index); // Menggunakan fungsi buildProductCard
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
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return buildProductCard(
                            index); // Menggunakan fungsi buildProductCard
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                            height: 16); // Menambah jarak antar item
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
