// ignore_for_file: deprecated_member_use
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "dashboard/dashboard_inicio.dart";
import "package:inventario/screens/alertas_stock_view.dart";
import "package:inventario/screens/calzado_view.dart";
import "package:inventario/screens/materiales_view.dart";
import "package:inventario/screens/login_page.dart";
import "package:inventario/screens/carrito_screen.dart";
import "package:inventario/core/providers/carrito_provider.dart";
import "package:inventario/core/providers/reporte_provider.dart";
import "package:inventario/core/providers/notificacion_provider.dart";
import "package:inventario/screens/reportes/reporte_screen.dart";
import "package:inventario/screens/configuracion/configuracion_screen.dart";
import 'package:inventario/core/widgets/panel_notificaciones.dart';

// ==================== NAVEGACIÓN PRINCIPAL ====================
class AppNavigation extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  const AppNavigation({super.key, this.usuario});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  String page = "Dashboard";

  // ==================== DATOS DEL USUARIO (SOLO PARA PÁGINAS) ====================
  String get usuarioID =>
      widget.usuario?["id"] ?? widget.usuario?["UsuarioID"] ?? "USR00001";

  // ==================== CONFIGURACIÓN DE PÁGINAS ====================
  Map<String, dynamic> get pageConfig => _pages[page] ?? _pages["Dashboard"]!;

  Map<String, dynamic> get _pages => {
    "Dashboard": {
      "icon": Icons.dashboard_rounded,
      "color": Colors.blue,
      "subtitle": "Resumen del taller",
      "widget": const DashboardInicio(),
    },
    "Zapatos": {
      "icon": Icons.shopping_bag_rounded,
      "color": Colors.brown,
      "subtitle": "Inventario de calzado",
      "widget": const CalzadosView(),
    },
    "Materiales": {
      "icon": Icons.inventory_2_rounded,
      "color": Colors.green,
      "subtitle": "Gestión de materiales",
      "widget": MaterialesView(usuarioID: usuarioID),
    },
    "Alertas": {
      "icon": Icons.warning_amber_rounded,
      "color": Colors.orange,
      "subtitle": "Control de stock",
      "widget": const AlertasStockView(),
    },
    "Reportes": {
      "icon": Icons.bar_chart_rounded,
      "color": Colors.purple,
      "subtitle": "Estadísticas y gráficos",
      "widget": const ReporteScreen(),
    },
    "Configuración": {
      "icon": Icons.settings_rounded,
      "color": Colors.grey,
      "subtitle": "Ajustes del sistema",
      "widget": ConfiguracionScreen(usuario: widget.usuario),
    },
  };

  void _navegarAlCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CarritoScreen()),
    ).then((_) {
      final carritoProvider = Provider.of<CarritoProvider>(
        context,
        listen: false,
      );
      carritoProvider.inicializarCarrito(usuarioID, context: context);
    });
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => ReporteProvider())],
    child: Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    ),
  );

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar() {
    final carritoProvider = Provider.of<CarritoProvider>(context);
    final notificacionProvider = Provider.of<NotificacionProvider>(context);

    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (pageConfig["color"] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              pageConfig["icon"] as IconData,
              color: pageConfig["color"] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page == "Dashboard" ? "Taller de Calzado" : page,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (pageConfig["subtitle"] != "")
                  Text(
                    pageConfig["subtitle"] as String,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        // Carrito
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    carritoProvider.items.isNotEmpty
                        ? Icons.shopping_cart_rounded
                        : Icons.shopping_cart_outlined,
                    key: ValueKey(carritoProvider.items.isNotEmpty),
                    color: carritoProvider.items.isNotEmpty
                        ? Colors.green.shade700
                        : Colors.black87,
                    size: 28,
                  ),
                ),
                onPressed: _navegarAlCarrito,
                tooltip: carritoProvider.items.isNotEmpty
                    ? "Carrito (${carritoProvider.cantidadTotal} items)"
                    : "Ver carrito",
              ),
              if (carritoProvider.items.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade700.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        carritoProvider.cantidadTotal > 9
                            ? '9+'
                            : carritoProvider.cantidadTotal.toString(),
                        key: ValueKey(carritoProvider.cantidadTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Notificaciones
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: _showNotifications,
              tooltip: "Notificaciones",
            ),
            if (notificacionProvider.tieneNotificaciones)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificacionProvider.notificaciones.length > 9
                        ? '9+'
                        : notificacionProvider.notificaciones.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ==================== DRAWER ====================
  Widget _buildDrawer() => Drawer(
    elevation: 8,
    child: Column(
      children: [
        // ==========================================
        // HEADER SIMPLIFICADO (SIN PERFIL)
        // ==========================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 40,
            left: 20,
            right: 20,
            bottom: 24,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE), Color(0xFFE0E0E0)],
            ),
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Taller de Calzado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Sistema de Gestión',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // ==========================================
        // MENÚ DE NAVEGACIÓN
        // ==========================================
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _drawerItem("Dashboard"),
              _drawerItem("Zapatos"),
              _drawerItem("Materiales"),
              _drawerItem("Alertas"),
              const Divider(height: 24),
              _drawerItem("Reportes"),
              _drawerItem("Configuración"),
            ],
          ),
        ),
        // ==========================================
        // BOTÓN DE CERRAR SESIÓN
        // ==========================================
        Container(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text(
              "Cerrar Sesión",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: _showLogoutDialog,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withOpacity(0.2), width: 1),
            ),
          ),
        ),
      ],
    ),
  );

  // ==================== DRAWER ITEM ====================
  Widget _drawerItem(String id) {
    final config = _pages[id]!;
    final isSelected = page == id;

    // Configuración usa Navigator.push
    if (id == "Configuración") {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: ListTile(
          leading: Icon(
            config["icon"] as IconData,
            color: isSelected ? Colors.black87 : config["color"] as Color,
          ),
          title: Text(
            id == "Dashboard" ? "Inicio" : id,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ConfiguracionScreen(usuario: widget.usuario),
              ),
            );
          },
          selected: isSelected,
          selectedTileColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Resto de items
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          config["icon"] as IconData,
          color: isSelected ? Colors.black87 : config["color"] as Color,
        ),
        title: Text(
          id == "Dashboard" ? "Inicio" : id,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        onTap: () => _navigateTo(id),
        selected: isSelected,
        selectedTileColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==================== BODY ====================
  Widget _buildBody() => SafeArea(
    bottom: false,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Builder(
        key: ValueKey<String>(page),
        builder: (_) => pageConfig["widget"] as Widget,
      ),
    ),
  );

  // ==================== MÉTODOS ====================
  void _navigateTo(String newPage) {
    setState(() {
      page = newPage;
      Navigator.pop(context);
    });
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const PanelNotificaciones(),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "¿Cerrar Sesión?",
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
        content: const Text(
          "¿Estás seguro de que deseas salir del sistema del taller?",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("SALIR"),
          ),
        ],
      ),
    );
  }
}
