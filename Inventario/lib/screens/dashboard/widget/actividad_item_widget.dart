import 'package:flutter/material.dart';
import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/models/actividad_item.dart';

class ActividadItemWidget extends StatelessWidget {
  final ActividadItem item;
  final VoidCallback onTap;

  const ActividadItemWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(item);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono según el tipo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: config.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(config.icon, color: config.iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.descripcion,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.movimiento,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      item.encargado,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              // Cantidad
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: config.badgeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: config.badgeText.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.cantidad,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: config.badgeText,
                      ),
                    ),
                    if (item.tieneDetalle)
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Colors.grey,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Configuración visual según el tipo
  _Config _getConfig(ActividadItem item) {
    if (item.tipo == 'VENTA') {
      return _Config(
        icon: Icons.shopping_cart_rounded,
        iconBg: Colors.green.shade50,
        iconColor: Colors.green.shade700,
        badgeBg: Colors.green.shade50,
        badgeText: Colors.green.shade700,
      );
    }

    if (item.tipo == 'PRODUCCION') {
      return _Config(
        icon: Icons.factory_rounded,
        iconBg: Colors.purple.shade50,
        iconColor: Colors.purple.shade700,
        badgeBg: Colors.purple.shade50,
        badgeText: Colors.purple.shade700,
      );
    }

    // Para materiales, analizar el movimiento
    final movimiento = item.movimiento.toLowerCase();
    if (movimiento.contains('ingreso') ||
        movimiento.contains('abastecimiento')) {
      return _Config(
        icon: Icons.local_shipping_rounded,
        iconBg: Colors.blue.shade50,
        iconColor: Colors.blue.shade700,
        badgeBg: Colors.blue.shade50,
        badgeText: Colors.blue.shade700,
      );
    } else if (movimiento.contains('consumo')) {
      return _Config(
        icon: Icons.build_rounded,
        iconBg: Colors.orange.shade50,
        iconColor: Colors.orange.shade700,
        badgeBg: Colors.orange.shade50,
        badgeText: Colors.orange.shade700,
      );
    } else if (movimiento.contains('descarte')) {
      return _Config(
        icon: Icons.delete_forever_rounded,
        iconBg: Colors.red.shade50,
        iconColor: Colors.red.shade700,
        badgeBg: Colors.red.shade50,
        badgeText: Colors.red.shade700,
      );
    }

    return _Config(
      icon: Icons.inventory_2_rounded,
      iconBg: Colors.grey.shade50,
      iconColor: Colors.grey.shade700,
      badgeBg: Colors.grey.shade50,
      badgeText: Colors.grey.shade700,
    );
  }
}

class _Config {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color badgeBg;
  final Color badgeText;

  _Config({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeBg,
    required this.badgeText,
  });
}
