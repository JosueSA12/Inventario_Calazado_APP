import 'package:flutter/material.dart';
import 'package:inventario/core/theme/app_colors.dart';

class TarjetaKpi extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;
  final IconData icono;

  const TarjetaKpi({
    super.key,
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 26),
          ),

          const SizedBox(height: 12),

          // Título
          Text(
            titulo,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Número grande
          Text(
            valor,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
