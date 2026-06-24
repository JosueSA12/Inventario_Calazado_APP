import 'package:flutter/material.dart';
import 'package:pandabar/pandabar.dart';
import 'package:inventario/screens/materiales_view.dart';
import 'package:inventario/dashboard/dashboard_inicio.dart';
import 'package:inventario/screens/formulario_resgistrar_calzado.dart';
import 'package:inventario/screens/formulario_registrar_material.dart';
import 'package:inventario/screens/alertas_view.dart';
import 'package:inventario/screens/calzado_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String page = 'Dashboard';

  void _mostrarOpcionesDeRegistro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué deseas registrar hoy?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Opción: Nuevo Calzado
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.brown.shade100,
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.brown,
                  ),
                ),
                title: const Text('Nuevo Calzado '),
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
              const Divider(),
              // Opción: Nuevo Material
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.layers_rounded, color: Colors.blue),
                ),
                title: const Text('Nueva Materia Prima / Insumo'),
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
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.brown.shade100,
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.brown,
                  ),
                ),
                title: const Text('Registrar Venta'),
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
      bottomNavigationBar: PandaBar(
        fabColors: [
          const Color.fromARGB(255, 1, 179, 39),
          const Color.fromARGB(255, 1, 199, 83),
        ],
        fabIcon: const Icon(Icons.add, color: Colors.white, size: 28),

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
              return const DashboardInicio(); //DashboardInicio
            case 'Zapatos':
              return const CalzadosView(); //Calzados Screen
            case 'Materiales':
              return const MaterialesView(); //Materiales Screen
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
