import 'package:flutter/material.dart';

class EmptyAlertasState extends StatelessWidget {
  const EmptyAlertasState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: Colors.green,
          ),
          SizedBox(height: 16),
          Text(
            '¡Todo en orden!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'No hay alertas con los filtros actuales',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
