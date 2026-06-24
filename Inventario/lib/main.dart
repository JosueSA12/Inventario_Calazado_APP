import 'package:flutter/material.dart';
import 'package:inventario/home.dart';

void main() {
  runApp(const MiTallerApp());
}

class MiTallerApp extends StatelessWidget {
  const MiTallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taller de Calzado',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
