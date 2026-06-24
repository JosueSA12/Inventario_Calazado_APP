import 'package:flutter/material.dart';
import 'package:pandabar/pandabar.dart';

import 'package:inventario/screens/materiales_view.dart';
import 'package:inventario/dashboard/dashboard_inicio.dart';
import 'package:inventario/formularios/formulario_resgistrar_calzado.dart';
import 'package:inventario/formularios/formulario_registrar_material.dart';
import 'package:inventario/screens/alertas_stock_view.dart';
import 'package:inventario/screens/calzado_view.dart';

import 'core/theme/app_colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String page = 'Dashboard';

  void _mostrarOpcionesDeRegistro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué deseas registrar hoy?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 24),

              // Opción: Nuevo Calzado
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.categoriaEstiloFondo,
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: AppColors.categoriaEstiloIcono,
                  ),
                ),
                title: const Text(
                  'Nuevo Calzado',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormularioCalzado(),
                    ),
                  );
                },
              ),
              const Divider(color: Color(0xFFEFECE9)),

              // Opción: Nuevo Material
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.categoriaMaterialFondo,
                  child: Icon(
                    Icons.layers_rounded,
                    color: AppColors.categoriaMaterialIcono,
                  ),
                ),
                title: const Text(
                  'Nueva Materia Prima / Insumo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormularioMaterial(),
                    ),
                  );

                  if (resultado == true && page == 'Materiales') {
                    setState(() {});
                  }
                },
              ),
              const Divider(color: Color(0xFFEFECE9)),

              // Opción: Registrar Venta
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.salidaFondo,
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.salidaTexto,
                  ),
                ),
                title: const Text(
                  'Registrar Venta',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormularioCalzado(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      bottomNavigationBar: PandaBar(
        backgroundColor: AppColors.surface,
        // Mantienes tus colores llamativos para el botón de acción principal
        fabColors: const [Color(0xFF01B327), Color(0xFF01C753)],
        fabIcon: const Icon(Icons.add, color: Colors.white, size: 28),

        //ActiveColor: AppColors.primary,
        //unselectedColor: AppColors.textLight,
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
            icon: Icons.layers_rounded,
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
      body: Builder(
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
    );
  }
}
