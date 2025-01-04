import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileEditForm extends StatefulWidget {
  final String currentName;
  final String currentEmail;

  const ProfileEditForm(
      {Key? key, required this.currentName, required this.currentEmail})
      : super(key: key);

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;

  final secureStorage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.18.60:8000/api';

  @override
  void initState() {
    super.initState();
    _name = widget.currentName;
    _email = widget.currentEmail;
  }

  Future<void> _updateUserProfile() async {
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception('Access token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/user/update'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _name,
          'email': _email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        final error = jsonDecode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (value) => _name = value,
            validator: (value) =>
                value!.isEmpty ? 'Name cannot be empty' : null,
          ),
          TextFormField(
            initialValue: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (value) => _email = value,
            validator: (value) => value!.isEmpty || !value.contains('@')
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateUserProfile();
              }
            },
            child: const Text('Update Profile'),
          ),
        ],
      ),
    );
  }
}
