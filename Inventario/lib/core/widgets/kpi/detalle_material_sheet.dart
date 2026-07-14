import "package:flutter/material.dart";
import "package:inventario/core/theme/app_colors.dart";

/// ======================
/// DETALLE PARA ALERTA (Stock Crítico)
/// ======================
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.kpiAlertas.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.kpiAlertas,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.kpiAlertas.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "STOCK CRÍTICO",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.kpiAlertas,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insumo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.2),

          _buildInfoRow("📋 Código", codigo, isCode: true),
          _buildInfoRow("📂 Categoría", categoria),
          _buildInfoRow(
            "🏢 Proveedor",
            proveedor.isEmpty ? "Sin proveedor" : proveedor,
          ),
          _buildInfoRow("📦 Stock Actual", "$cantidad $medida", isDanger: true),

          const SizedBox(height: 32),

          // ==========================================
          // BOTÓN GESTIONAR ABASTECIMIENTO
          // ==========================================
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOrdenarMas ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: const Text(
                    "Gestionar Abastecimiento",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kpiAlertas,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ==========================================
          // BOTÓN CERRAR (MEJORADO)
          // ==========================================
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 20),
              label: const Text(
                "Cerrar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
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
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isDanger ? AppColors.kpiAlertas : AppColors.textDark,
                fontSize: isDanger ? 17 : 15,
                fontWeight: (isDanger || isCode)
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontFamily: isCode ? "monospace" : null,
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
/// ======================
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FICHA DE MATERIAL",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insumo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.2),

          _buildInfoRow("📋 Código", codigo, isCode: true),
          _buildInfoRow("📂 Categoría", categoria),
          _buildInfoRow(
            "🏢 Proveedor",
            proveedor.isEmpty ? "Sin proveedor" : proveedor,
          ),
          _buildInfoRow(
            "📦 Stock Disponible",
            "$cantidad $medida",
            isSuccess: true,
          ),

          const SizedBox(height: 24),

          // ==========================================
          // BOTÓN CERRAR
          // ==========================================
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text(
                "Cerrar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
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
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isSuccess ? AppColors.entradaTexto : AppColors.textDark,
                fontSize: isSuccess ? 17 : 15,
                fontWeight: (isSuccess || isCode)
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontFamily: isCode ? "monospace" : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
