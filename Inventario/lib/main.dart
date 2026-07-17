import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:inventario/core/providers/produccion_provider.dart";
import "package:provider/provider.dart";
import "core/theme/app_theme.dart";
import "screens/login_page.dart";
import "core/providers/carrito_provider.dart";
import 'core/providers/reporte_provider.dart';
import 'core/providers/notificacion_provider.dart';
import 'package:inventario/core/providers/dashboard_provider.dart';

void main() {
  runApp(const MiTallerApp());
}

class MiTallerApp extends StatelessWidget {
  const MiTallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => ReporteProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProduccionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Taller de Calzado",
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
        home: const LoginScreen(),
      ),
    );
  }
}
