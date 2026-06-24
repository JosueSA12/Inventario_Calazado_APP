import 'package:flutter/material.dart';
import 'package:inventario/core/theme/app_colors.dart';

/// ======================
/// DETALLE PARA ALERTA (Stock Crítico)
// ======================
class DetalleBajoStockSheet extends StatelessWidget {
  final String codigo;
  final String insumo;
  final String categoria;
  final double cantidad;
  final String medida;
  final String proveedor;
  final VoidCallback? onOrdenarMas;

  const DetalleBajoStockSheet({
    super.key,
    required this.codigo,
    required this.insumo,
    required this.categoria,
    required this.cantidad,
    required this.medida,
    required this.proveedor,
    this.onOrdenarMas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 24),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kpiAlertas.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.kpiAlertas,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALERTA - STOCK CRÍTICO',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.kpiAlertas,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      insumo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.2),

          _buildInfoRow('Código', codigo, isCode: true),
          _buildInfoRow('Categoría', categoria),
          _buildInfoRow('Proveedor', proveedor),
          _buildInfoRow('Stock Actual', '$cantidad $medida', isDanger: true),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onOrdenarMas ?? () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: const Text(
                'Gestionar Abastecimiento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kpiAlertas,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() => Center(
    child: Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isCode = false,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textLight, fontSize: 13.5),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isDanger ? AppColors.kpiAlertas : AppColors.textDark,
                fontSize: isDanger ? 16.5 : 14.5,
                fontWeight: (isDanger || isCode)
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontFamily: isCode ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================
/// DETALLE GENERAL DE MATERIAL
// ======================
class DetalleMaterialGeneralSheet extends StatelessWidget {
  final String codigo;
  final String insumo;
  final String categoria;
  final double cantidad;
  final String medida;
  final String proveedor;

  const DetalleMaterialGeneralSheet({
    super.key,
    required this.codigo,
    required this.insumo,
    required this.categoria,
    required this.cantidad,
    required this.medida,
    required this.proveedor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 24),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FICHA DE MATERIAL',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      insumo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.2),

          _buildInfoRow('Código', codigo, isCode: true),
          _buildInfoRow('Categoría', categoria),
          _buildInfoRow('Proveedor', proveedor),
          _buildInfoRow(
            'Stock Disponible',
            '$cantidad $medida',
            isSuccess: true,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDragHandle() => Center(
    child: Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isCode = false,
    bool isSuccess = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textLight, fontSize: 13.5),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isSuccess ? AppColors.entradaTexto : AppColors.textDark,
                fontSize: isSuccess ? 16.5 : 14.5,
                fontWeight: (isSuccess || isCode)
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontFamily: isCode ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================
/// DETALLE DE MOVIMIENTO DE MATERIAL
// ======================
class DetalleMovimientoSheet extends StatelessWidget {
  final String fecha;
  final String tipo;
  final String descripcion;
  final String cantidad;
  final String movimiento;
  final String encargado;

  const DetalleMovimientoSheet({
    super.key,
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.cantidad,
    required this.movimiento,
    required this.encargado,
  });

  @override
  Widget build(BuildContext context) {
    final bool esSalida = movimiento.toLowerCase().contains('salida');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 24),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: esSalida
                      ? AppColors.salidaFondo
                      : AppColors.entradaFondo,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  esSalida
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: esSalida
                      ? AppColors.salidaTexto
                      : AppColors.entradaTexto,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DETALLE DEL MOVIMIENTO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          _buildInfoRow('Fecha', fecha.isNotEmpty ? fecha.split('T')[0] : '-'),
          _buildInfoRow('Tipo', tipo),
          _buildInfoRow('Movimiento', movimiento),
          _buildInfoRow('Cantidad', cantidad, isHighlight: true),
          _buildInfoRow('Encargado', encargado),
        ],
      ),
    );
  }

  Widget _buildDragHandle() => Center(
    child: Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(label)),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
