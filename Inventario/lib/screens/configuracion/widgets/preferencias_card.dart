import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/configuracion_provider.dart';

class PreferenciasCard extends StatelessWidget {
  const PreferenciasCard({super.key});

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfiguracionProvider>();

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
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Preferencias',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded),
              title: const Text('Modo oscuro'),
              subtitle: const Text('Activar tema oscuro'),
              value: configProvider.modoOscuro,
              onChanged: (value) {
                configProvider.setModoOscuro(value);
                _mostrarSnackBar(
                  context,
                  value ? 'Modo oscuro activado' : 'Modo claro activado',
                  Colors.blue,
                );
              },
              activeColor: Colors.blue,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.sync_rounded),
              title: const Text('Sincronización automática'),
              subtitle: const Text('Sincronizar en segundo plano'),
              value: configProvider.sincronizacion,
              onChanged: configProvider.setSincronizacion,
              activeColor: Colors.blue,
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
