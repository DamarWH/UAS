import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/service/Service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();
const String baseUrl =
    'http://192.168.18.60:8000/api'; // Replace with your API URL

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isAuthenticated = false;
  String _fullName = "Loading...";
  String _email = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _fullName = data['name'] ?? "No name available";
          _email = data['email'] ?? "No email available";
          _isAuthenticated = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
        _showErrorDialog('Failed to fetch user data: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('An error occurred: $e');
    }
  }

  Future<void> _updateUserProfile(String username) async {
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception('Access token not found');
      }

      // Prepare the body as a JSON object
      final response = await http.put(
        Uri.parse('$baseUrl/user/update'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username, // Ensure username is sent as a string
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() {
          _fullName = username;
        });
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update profile: ${error['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
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

  void _showEditProfileDialog() {
    final _formKey = GlobalKey<FormState>();
    String newUsername = _fullName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: _fullName,
                    decoration: const InputDecoration(labelText: 'Username'),
                    onChanged: (value) => newUsername = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Username cannot be empty' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop();
                        _updateUserProfile(newUsername);
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 215, 163, 67),
      ),
      backgroundColor: const Color.fromARGB(255, 215, 163, 67),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildUserInfo(),
                  const SizedBox(height: 20),
                  _buildListView(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 34, 34, 34),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Email: $_email",
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 116, 116, 116),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildListTile("Edit Profile", Icons.edit, _showEditProfileDialog),
        _buildListTile("Logout", Icons.logout, () async {
          await secureStorage.delete(key: 'access_token');
          Navigator.pushReplacementNamed(context, '/login');
        }),
        _buildListTile("Delete Account", Icons.delete, () async {
          bool? confirmDelete = await _showConfirmationDialog(
            title: "Delete Account",
            content:
                "Are you sure you want to delete your account? This action cannot be undone.",
          );
          if (confirmDelete == true) {
            try {
              await delete();
              Navigator.pushReplacementNamed(context, '/login');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete account: $e')),
              );
            }
          }
        }),
        _buildListTile("View Brands", Icons.business, () {
          Navigator.pushNamed(context, '/brands'); // Navigate to BrandPage
        }),
      ],
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
