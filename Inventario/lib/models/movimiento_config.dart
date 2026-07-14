import 'package:flutter/material.dart';
import 'package:inventario/core/theme/app_colors.dart';

class MovimientoConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color badgeBg;
  final Color badgeText;

  const MovimientoConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.badgeBg,
    required this.badgeText,
  });

  static Map<String, MovimientoConfig> get configs => {
    'venta': MovimientoConfig(
      icon: Icons.sell_rounded,
      iconColor: const Color(0xFF2E7D32),
      iconBg: const Color(0xFFE8F5E9),
      badgeBg: const Color(0xFFE8F5E9),
      badgeText: const Color(0xFF2E7D32),
    ),
    'eliminado': MovimientoConfig(
      icon: Icons.delete_rounded,
      iconColor: const Color(0xFFC62828),
      iconBg: const Color(0xFFFFEBEE),
      badgeBg: AppColors.salidaFondo,
      badgeText: AppColors.salidaTexto,
    ),
    'consumo': MovimientoConfig(
      icon: Icons.settings_rounded,
      iconColor: const Color(0xFFEF6C00),
      iconBg: const Color(0xFFFFF3E0),
      badgeBg: AppColors.salidaFondo,
      badgeText: AppColors.salidaTexto,
    ),
    'ingreso': MovimientoConfig(
      icon: Icons.download_rounded,
      iconColor: const Color(0xFF1565C0),
      iconBg: const Color(0xFFE3F2FD),
      badgeBg: AppColors.entradaFondo,
      badgeText: AppColors.entradaTexto,
    ),
    'produccion': MovimientoConfig(
      icon: Icons.assignment_rounded,
      iconColor: const Color(0xFF6A1B9A),
      iconBg: const Color(0xFFF3E5F5),
      badgeBg: AppColors.entradaFondo,
      badgeText: AppColors.entradaTexto,
    ),
  };

  static MovimientoConfig getDefault(bool esMaterial) {
    return MovimientoConfig(
      icon: esMaterial ? Icons.inventory_2_rounded : Icons.style_rounded,
      iconColor: Colors.grey.shade700,
      iconBg: Colors.grey.shade200,
      badgeBg: AppColors.entradaFondo,
      badgeText: AppColors.entradaTexto,
    );
  }

  static MovimientoConfig fromMovimiento(String movimiento, bool esMaterial) {
    final lowerMovimiento = movimiento.toLowerCase();
    String tipo = 'default';

    if (lowerMovimiento.contains('venta')) {
      tipo = 'venta';
    } else if (lowerMovimiento.contains('eliminado') ||
        lowerMovimiento.contains('descarte')) {
      tipo = 'eliminado';
    } else if (lowerMovimiento.contains('consumo') ||
        lowerMovimiento.contains('taller')) {
      tipo = 'consumo';
    } else if (lowerMovimiento.contains('ingreso') ||
        lowerMovimiento.contains('abastecimiento') ||
        lowerMovimiento.contains('compra')) {
      tipo = 'ingreso';
    } else if (lowerMovimiento.contains('producción') ||
        lowerMovimiento.contains('terminad')) {
      tipo = 'produccion';
    }

    return configs[tipo] ?? getDefault(esMaterial);
  }
}
