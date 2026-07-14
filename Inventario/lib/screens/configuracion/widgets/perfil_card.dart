import 'package:flutter/material.dart';

class PerfilCard extends StatelessWidget {
  final String nombre;
  final String correo;
  final String rol;

  const PerfilCard({
    super.key,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Nombre'),
              subtitle: Text(nombre),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Correo'),
              subtitle: Text(correo),
            ),
            ListTile(
              leading: const Icon(Icons.verified_rounded),
              title: const Text('Rol'),
              subtitle: Text(rol),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Activo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
