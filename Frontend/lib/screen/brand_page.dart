import 'package:flutter/material.dart';
import 'package:frontend/service/Service_brand.dart';

class BrandPage extends StatefulWidget {
  @override
  _BrandPageState createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  bool _isLoading = true;
  List<dynamic> _brands = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  int? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      final brands = await fetchBrands(); // Fetch brands from the service
      setState(() {
        _brands = brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to fetch brands: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openUpdateDialog(int brandId, String name, String description) {
    _nameController.text = name;
    _descriptionController.text = description;
    _selectedBrandId = brandId;

    if (_selectedBrandId == null) {
      _showErrorDialog("Invalid brand ID");
      return; // Exit if ID is invalid
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Brand'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Brand Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_selectedBrandId != null) {
                  await updateBrand(
                    brandId: _selectedBrandId!,
                    name: _nameController.text,
                    description: _descriptionController.text,
                  );
                  Navigator.of(context).pop();
                  _fetchBrands(); // Refresh the brand list
                }
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openAddBrandDialog() {
    _nameController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Brand'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Brand Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await addBrand(
                  name: _nameController.text,
                  description: _descriptionController.text,
                );
                Navigator.of(context).pop();
                _fetchBrands(); // Refresh the brand list
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Brands"),
        backgroundColor: const Color.fromARGB(255, 215, 163, 67),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _brands.length,
              itemBuilder: (context, index) {
                final brand = _brands[index];
                return ListTile(
                  title: Text(brand['name']),
                  subtitle: Text(
                      'ID: ${brand['id']} - ${brand['description']}'), // Show brand ID here
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _openUpdateDialog(
                            brand['id'],
                            brand['name'],
                            brand['description'],
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          if (brand['id'] != null) {
                            await deleteBrand(brand['id']);
                            _fetchBrands(); // Refresh the list
                          } else {
                            _showErrorDialog("Invalid brand ID");
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddBrandDialog,
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 215, 163, 67),
      ),
    );
  }
}
