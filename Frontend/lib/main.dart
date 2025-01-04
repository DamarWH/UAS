import 'package:frontend/screen/brand_page.dart';
import 'package:frontend/screen/home_page.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screen/profile.dart';
import 'package:frontend/screen/tambahshoes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/profile': (context) => ProfilePage(),
          '/home': (context) => HomeScreen(),
          '/shoes': (context) => AddShoesScreen(),
          '/brands': (context) => BrandPage()
        });
  }
}
