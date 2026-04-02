import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/shop_screen.dart';

void main() {
  runApp(const ProviderScope(child: CharityShopApp()));
}

class CharityShopApp extends StatelessWidget {
  const CharityShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charity Shop 3D',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
        useMaterial3: true,
      ),
      home: const ShopScreen(),
    );
  }
}
