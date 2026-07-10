import 'package:flutter/material.dart';

class CardError extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onRetry;

  const CardError({super.key, required this.mensaje, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensaje,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Colors.red.shade700,
              ),
              label: Text(
                'Reintentar',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
