import 'package:flutter/material.dart';
import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/core/utils/formatters.dart';

class DetalleVentaSheet extends StatelessWidget {
  final Map<String, dynamic> venta;
  final List<Map<String, dynamic>> items;

  const DetalleVentaSheet({
    super.key,
    required this.venta,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final totalPares = items.fold<int>(
      0,
      (sum, item) => sum + ((item['Cantidad'] ?? 0) as num).toInt(),
    );

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
          _buildInfoRow('Fecha', _formatFecha(venta['FechaVenta'])),
          _buildInfoRow('Hora', _formatHora(venta['FechaVenta'])),
          _buildInfoRow('Vendedor', venta['UsuarioNombre'] ?? '-'),
          _buildInfoRow(
            'Total',
            'S/. ${_formatMoneda(venta['Total'])}',
            isHighlight: true,
          ),
          _buildInfoRow('Items', '${items.length} productos'),
          _buildInfoRow('Total Pares', '$totalPares pares'),
          const SizedBox(height: 16),
          const Text(
            'PRODUCTOS VENDIDOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          // ✅ USAR EXPANDED + SINGLECHILDSCROLLVIEW
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: items
                    .map((item) => _buildProductoItem(item))
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
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_cart_rounded,
            color: Colors.green,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DETALLE DE VENTA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Venta #${venta['VentaID']}',
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
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Completada',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
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
                color: isHighlight ? Colors.green.shade700 : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['Modelo'] ?? 'Producto',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${item['Color'] ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Talla ${item['Talla'] ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'S/. ${_formatMoneda(item['Subtotal'])}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item['Cantidad']} x S/. ${_formatMoneda(item['PrecioUnitario'])}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
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

  String _formatMoneda(dynamic valor) {
    final numero = FormatterUtils.getNumericValue(valor);
    final double cantidad = double.tryParse(numero) ?? 0.0;
    return cantidad.toStringAsFixed(2);
  }
}
