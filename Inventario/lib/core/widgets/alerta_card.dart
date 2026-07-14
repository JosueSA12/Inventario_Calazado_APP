import "package:flutter/material.dart";
import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/clases/alerta_material.dart";

class AlertaCard extends StatelessWidget {
  final AlertaMaterial material;
  final VoidCallback onTap;

  const AlertaCard({super.key, required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.kpiAlertas.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ==========================================
              // ICONO DE ALERTA
              // ==========================================
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.kpiAlertas.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.kpiAlertas,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // ==========================================
              // INFORMACIÓN
              // ==========================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.insumo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kpiAlertas.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            material.categoria,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.kpiAlertas,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          material.proveedor,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        Text(
                          "Stock: ${material.cantidad.toStringAsFixed(1)} ${material.medida}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.kpiAlertas,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==========================================
              // FLECHA
              // ==========================================
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
