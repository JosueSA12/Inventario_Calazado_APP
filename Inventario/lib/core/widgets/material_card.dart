import "package:flutter/material.dart";
import "package:inventario/clases/mostrar_material.dart";
import "package:inventario/core/theme/app_colors.dart";

class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MaterialCard({
    super.key,
    required this.material,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool esBajoStock = material.cantidad < 5.0;

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
        border: esBajoStock
            ? Border.all(color: AppColors.kpiAlertas, width: 1.5)
            : null,
      ),
      child: Stack(
        children: [
          // ==========================================
          // CONTENIDO PRINCIPAL
          // ==========================================
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ==========================================
                  // ICONO
                  // ==========================================
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        material.categoria,
                      ).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getCategoryIcon(material.categoria),
                      color: _getCategoryColor(material.categoria),
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ==========================================
                  // INFORMACIÓN
                  // ==========================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                material.insumo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
                                color: _getCategoryColor(
                                  material.categoria,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                material.categoria,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _getCategoryColor(material.categoria),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          material.proveedor,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              "${material.cantidad.toStringAsFixed(1)} ${material.medida}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: esBajoStock
                                    ? AppColors.kpiAlertas
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ==========================================
                  // ACCIONES
                  // ==========================================
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (esBajoStock)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.kpiAlertas,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kpiAlertas.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Stock Bajo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case "Cuero":
        return Icons.style_rounded;
      case "Suelas":
        return Icons.shop_two_rounded;
      case "Hilos":
        return Icons.timeline_rounded;
      case "Pegamentos / Tintes":
        return Icons.color_lens_rounded;
      case "Herrajes / Ojales":
        return Icons.build_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case "Cuero":
        return Colors.brown.shade700;
      case "Suelas":
        return Colors.blue.shade700;
      case "Hilos":
        return Colors.purple.shade700;
      case "Pegamentos / Tintes":
        return Colors.orange.shade700;
      case "Herrajes / Ojales":
        return Colors.grey.shade700;
      default:
        return AppColors.primary;
    }
  }
}
