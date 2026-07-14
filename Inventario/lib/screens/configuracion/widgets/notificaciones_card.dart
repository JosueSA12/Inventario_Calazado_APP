import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/configuracion_provider.dart';
import 'package:inventario/core/providers/notificacion_provider.dart';

class NotificacionesCard extends StatelessWidget {
  const NotificacionesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfiguracionProvider>();
    final notificacionProvider = context.watch<NotificacionProvider>();

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
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_rounded),
              title: const Text('Notificaciones push'),
              subtitle: const Text('Recibir alertas en tiempo real'),
              value: configProvider.notificaciones,
              onChanged: (value) {
                configProvider.setNotificaciones(value);
                _mostrarSnackBar(
                  context,
                  value
                      ? 'Notificaciones activadas'
                      : 'Notificaciones desactivadas',
                  value ? Colors.green : Colors.orange,
                );
              },
              activeColor: Colors.blue,
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Historial'),
              subtitle: Text(
                '${notificacionProvider.notificaciones.length} notificaciones',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                _mostrarSnackBar(
                  context,
                  'Ver historial próximamente',
                  Colors.blue,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarSnackBar(BuildContext context, String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
