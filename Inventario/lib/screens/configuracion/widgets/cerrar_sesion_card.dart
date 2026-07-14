import 'package:flutter/material.dart';
import 'package:inventario/screens/login_page.dart';

class CerrarSesionCard extends StatelessWidget {
  const CerrarSesionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.logout_rounded, color: Colors.red),
          ),
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'Salir del sistema',
            style: TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: () => _mostrarDialogCerrarSesion(context),
        ),
      ),
    );
  }

  void _mostrarDialogCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
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
            child: const Text('SALIR'),
          ),
        ],
      ),
    );
  }
}
