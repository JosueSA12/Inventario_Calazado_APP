import "package:flutter/material.dart";
import "package:inventario/core/theme/app_colors.dart";

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
    final bool esSalida = movimiento.toLowerCase().contains("salida");
    final bool esVenta = movimiento.toLowerCase().contains("venta");
    final bool esProduccion =
        movimiento.toLowerCase().contains("producción") ||
        movimiento.toLowerCase().contains("terminad");
    final bool esAbastecimiento =
        movimiento.toLowerCase().contains("ingreso") ||
        movimiento.toLowerCase().contains("abastecimiento");
    final bool esConsumo = movimiento.toLowerCase().contains("consumo");
    final bool esDescarte =
        movimiento.toLowerCase().contains("eliminado") ||
        movimiento.toLowerCase().contains("descarte");

    // Seleccionar icono según el tipo de movimiento
    IconData iconoSeleccionado;
    Color colorIcono;
    Color colorFondo;

    if (esVenta) {
      iconoSeleccionado = Icons.shopping_cart_rounded;
      colorIcono = const Color(0xFF2E7D32);
      colorFondo = const Color(0xFFE8F5E9);
    } else if (esProduccion) {
      iconoSeleccionado = Icons.factory_rounded;
      colorIcono = const Color(0xFF6A1B9A);
      colorFondo = const Color(0xFFF3E5F5);
    } else if (esAbastecimiento) {
      iconoSeleccionado = Icons.local_shipping_rounded;
      colorIcono = const Color(0xFF1565C0);
      colorFondo = const Color(0xFFE3F2FD);
    } else if (esConsumo) {
      iconoSeleccionado = Icons.build_rounded;
      colorIcono = const Color(0xFFEF6C00);
      colorFondo = const Color(0xFFFFF3E0);
    } else if (esDescarte) {
      iconoSeleccionado = Icons.delete_forever_rounded;
      colorIcono = const Color(0xFFC62828);
      colorFondo = const Color(0xFFFFEBEE);
    } else {
      // Default según sea salida o entrada
      if (esSalida) {
        iconoSeleccionado = Icons.arrow_upward_rounded;
        colorIcono = AppColors.salidaTexto;
        colorFondo = AppColors.salidaFondo;
      } else {
        iconoSeleccionado = Icons.arrow_downward_rounded;
        colorIcono = AppColors.entradaTexto;
        colorFondo = AppColors.entradaFondo;
      }
    }

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

          // ==========================================
          // HEADER
          // ==========================================
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorFondo,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconoSeleccionado, color: colorIcono, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTipoMovimiento(movimiento),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorIcono,
                      ),
                    ),
                    Text(
                      descripcion,
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
          const Divider(height: 32),

          // ==========================================
          // CAMPOS DEL DETALLE
          // ==========================================
          _buildInfoRow("Fecha", fecha.isNotEmpty ? fecha.split("T")[0] : "-"),
          _buildInfoRow("Tipo", tipo),
          _buildInfoRow("Movimiento", movimiento),
          _buildInfoRow("Cantidad", cantidad, isHighlight: true),
          _buildInfoRow("Encargado", encargado),

          // ==========================================
          // BOTÓN DE CERRAR
          // ==========================================
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
              label: const Text(
                "Cerrar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 241, 93, 93),
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

  String _getTipoMovimiento(String movimiento) {
    final lower = movimiento.toLowerCase();
    if (lower.contains("venta")) {
      return "VENTA REALIZADA";
    } else if (lower.contains("producción") || lower.contains("terminad")) {
      return "PRODUCCIÓN";
    } else if (lower.contains("ingreso") || lower.contains("abastecimiento")) {
      return "ABASTECIMIENTO";
    } else if (lower.contains("consumo")) {
      return "CONSUMO DE MATERIAL";
    } else if (lower.contains("eliminado") || lower.contains("descarte")) {
      return "DESCARTE";
    } else {
      return "MOVIMIENTO";
    }
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
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                fontSize: isHighlight ? 16 : 14,
                color: isHighlight ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
