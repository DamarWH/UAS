import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/service/auth_login.dart';
import 'package:http/http.dart' as http;

const secureStorage = FlutterSecureStorage();
const String baseUrl =
    'http://172.20.10.2:8000/api'; // Replace with your API URL

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
    _fetchUserData(); // Fetch the user data on init
  }

  Future<void> _fetchUserData() async {
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        setState(() {
          _isLoading = false;
        });
        return; // Token is not found, no need to continue
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/user/profile'), // Make sure this is the correct endpoint
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _fullName =
              data['name'] ?? "No name available"; // Handle missing data
          _email = data['email'] ?? "No email available"; // Handle missing data
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
        _isLoading = false; // Set loading to false on error
      });
      _showErrorDialog('An error occurred: $e');
    }
  }

  // Show error message dialog
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

  // Confirm deletion of user account
  Future<void> _confirmDeleteAccount() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: <Widget>[
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

    if (confirmation == true) {
      await deleteUserAccount();
      Navigator.pushReplacementNamed(
          context, '/login'); // Redirect to login after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 215, 163, 67),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 215, 163, 67),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _isLoading
                ? const CircularProgressIndicator() // Show loading indicator while fetching data
                : _buildUserInfo(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildListTile("Notifications", Icons.notifications, () {
                    Navigator.pushNamed(context, '/notifications');
                  }),
                  _buildListTile("Privacy Policy", Icons.privacy_tip, () {
                    Navigator.pushNamed(context, '/privacyPolicy');
                  }),
                  _buildListTile("Terms of Service", Icons.description, () {
                    Navigator.pushNamed(context, '/termsOfService');
                  }),
                  _buildListTile("Logout", Icons.logout, () async {
                    await secureStorage.delete(key: 'access_token'); // Log out
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
                  _buildListTile(
                      "Delete Account", Icons.delete, _confirmDeleteAccount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display user info
  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            _fullName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "Email: $_email", // Display email instead of NPM
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  // List tile builder for options like notifications, logout, etc.
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
