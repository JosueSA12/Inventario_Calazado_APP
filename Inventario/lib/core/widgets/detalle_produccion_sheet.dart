import 'package:flutter/material.dart';
import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/core/utils/formatters.dart';

class DetalleProduccionSheet extends StatelessWidget {
  final Map<String, dynamic> orden;
  final List<Map<String, dynamic>> materiales;

  const DetalleProduccionSheet({
    super.key,
    required this.orden,
    required this.materiales,
  });

  @override
  Widget build(BuildContext context) {
    final totalMateriales = materiales.length;

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
          _buildHeader(),
          const Divider(height: 24, thickness: 1.2),
          _buildInfoRow('Fecha', _formatFecha(orden['OrdenFecha'])),
          _buildInfoRow('Hora', _formatHora(orden['OrdenFecha'])),
          _buildInfoRow('Operario', orden['Operario'] ?? '-'),
          _buildInfoRow('Modelo', orden['CalzadoModelo'] ?? '-'),
          _buildInfoRow('Color', orden['CalzadoColor'] ?? '-'),
          _buildInfoRow('Talla', orden['CalzadoTalla']?.toString() ?? '-'),
          _buildInfoRow(
            'Cantidad Producida',
            '${orden['CantidadPares'] ?? 0} pares',
            isHighlight: true,
          ),
          _buildInfoRow('Materiales', '$totalMateriales insumos'),
          const SizedBox(height: 16),
          const Text(
            'MATERIALES CONSUMIDOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: materiales
                    .map((item) => _buildMaterialItem(item))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCerrarButton(context),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.factory_rounded,
            color: Colors.purple,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DETALLE DE PRODUCCION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Orden #${orden['OrdenID']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Completada',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                fontSize: isHighlight ? 18 : 14,
                color: isHighlight
                    ? Colors.purple.shade700
                    : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['MaterialNombre'] ?? 'Material',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item['MaterialCategoria'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            FormatterUtils.formatCantidadConUnidad(
              item['CantidadConsumida'] ?? 0,
              item['MaterialMedida'] ?? '',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCerrarButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded, size: 20),
        label: const Text(
          'Cerrar',
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
    );
  }

  String _formatFecha(String? fecha) {
    if (fecha == null) return '-';
    return fecha.split('T')[0];
  }

  String _formatHora(String? fecha) {
    if (fecha == null) return '-';
    try {
      final parts = fecha.split('T');
      if (parts.length > 1) {
        return parts[1].substring(0, 5);
      }
      return '-';
    } catch (e) {
      return '-';
    }
  }
}
