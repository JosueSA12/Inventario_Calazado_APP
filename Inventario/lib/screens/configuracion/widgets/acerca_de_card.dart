import 'package:flutter/material.dart';

class AcercaDeCard extends StatelessWidget {
  const AcercaDeCard({super.key});

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
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_rounded, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Acerca de',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            const ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('Versión'),
              subtitle: Text('2.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.favorite_rounded, color: Colors.red),
              title: Text('Desarrollado por JosueSA24'),
              subtitle: Text('Flutter & Dart'),
            ),
          ],
        ),
      ),
    );
  }
}
