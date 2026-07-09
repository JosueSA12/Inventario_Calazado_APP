import 'package:flutter/material.dart';
import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/clases/alerta_material.dart';

class AlertaCard extends StatelessWidget {
  final AlertaMaterial material;
  final VoidCallback onTap;

  const AlertaCard({super.key, required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kpiAlertas.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.kpiAlertas.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.kpiAlertas.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.trending_down_rounded,
                    color: AppColors.kpiAlertas,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.insumo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${material.proveedor} • ${material.categoria}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${material.cantidad}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kpiAlertas,
                      ),
                    ),
                    if (material.medida.isNotEmpty)
                      Text(
                        material.medida,
                        style: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
