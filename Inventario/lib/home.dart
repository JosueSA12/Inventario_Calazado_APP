// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pandabar/pandabar.dart';

import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/dashboard/dashboard_inicio.dart';
import 'package:inventario/formularios/formulario_resgistrar_calzado.dart';
import 'package:inventario/formularios/formulario_registrar_material.dart';
import 'package:inventario/formularios/formulario_registrar_venta.dart';
import 'package:inventario/screens/alertas_stock_view.dart';
import 'package:inventario/screens/calzado_view.dart';
import 'package:inventario/screens/materiales_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // =========================================================================
  // ESTADOS Y VARIABLES
  // =========================================================================
  String page = 'Dashboard';

  // =========================================================================
  // VISTAS Y COMPONENTES DE INTERFAZ (MÉTODOS PRIVADOS)
  // =========================================================================

  /// Panel inferior
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  /// Acciones rápidas del taller
  void _mostrarOpcionesDeRegistro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 36.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Qué deseas gestionar hoy?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Opción: Nueva Orden de Producción / Lote de Calzado
              _buildOptionCard(
                title: 'Lote de Producción',
                subtitle: 'Registrar fabricación de calzado y consumo',
                icon: Icons.precision_manufacturing_rounded,
                iconColor: AppColors.categoriaEstiloIcono,
                backgroundColor: AppColors.categoriaEstiloFondo,
                onTap: () async {
                  Navigator.pop(context);
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormularioProduccionCalzado(),
                    ),
                  );
                  if (resultado == true) setState(() {});
                },
              ),
              const SizedBox(height: 12),

              // Opción: Agregar Materia Prima / Insumo
              _buildOptionCard(
                title: 'Materia Prima / Insumo',
                subtitle: 'Ingresar cuero, suelas, hilos o pegamentos',
                icon: Icons.layers_rounded,
                iconColor: AppColors.categoriaMaterialIcono,
                backgroundColor: AppColors.categoriaMaterialFondo,
                onTap: () async {
                  Navigator.pop(context);
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormularioMaterial(),
                    ),
                  );
                  if (resultado == true) setState(() {});
                },
              ),
              const SizedBox(height: 12),

              // Opción: Registrar Venta de Producto Terminado
              _buildOptionCard(
                title: 'Registrar Venta',
                subtitle: 'Salida de calzado terminado',
                icon: Icons.monetization_on_rounded,
                iconColor: AppColors.salidaTexto,
                backgroundColor: AppColors.salidaFondo,
                onTap: () async {
                  Navigator.pop(context);
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormularioRegistrarVenta(),
                    ),
                  );
                  if (resultado == true) setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // ÁRBOL DE COMPONENTES PRINCIPAL (BUILD)
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      bottomNavigationBar: PandaBar(
        backgroundColor: AppColors.surface,
        fabColors: const [Color(0xFF829F82), Color(0xFF6E8B6E)],
        fabIcon: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        buttonSelectedColor: const Color(0xFF3D2B1F),
        buttonData: [
          PandaBarButtonData(
            id: 'Dashboard',
            icon: Icons.dashboard_rounded,
            title: 'Inicio',
          ),
          PandaBarButtonData(
            id: 'Zapatos',
            icon: Icons.shopping_bag_rounded,
            title: 'Calzado',
          ),
          PandaBarButtonData(
            id: 'Materiales',
            icon: Icons.inventory_2_rounded,
            title: 'Materiales',
          ),
          PandaBarButtonData(
            id: 'Alertas',
            icon: Icons.warning_amber_rounded,
            title: 'Stock',
          ),
        ],
        onChange: (id) {
          setState(() {
            page = id;
          });
        },
        onFabButtonPressed: () {
          _mostrarOpcionesDeRegistro(context);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Builder(
            key: ValueKey<String>(page),
            builder: (context) {
              switch (page) {
                case 'Dashboard':
                  return const DashboardInicio();
                case 'Zapatos':
                  return const CalzadosView();
                case 'Materiales':
                  return const MaterialesView();
                case 'Alertas':
                  return const AlertasStockView();
                default:
                  return const Center(child: Text('Página no encontrada'));
              }
            },
          ),
        ),
      ),
    );
  }
}
