import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'home.dart';

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

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      home: const Home(),
    );
  }
}
