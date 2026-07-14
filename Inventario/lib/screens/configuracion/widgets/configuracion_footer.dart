import 'package:flutter/material.dart';

class ConfiguracionFooter extends StatelessWidget {
  const ConfiguracionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'Taller de Calzado v2.0.0',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            '© ${DateTime.now().year} - Todos los derechos reservados',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
