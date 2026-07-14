import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/reporte_provider.dart';

class ReporteStockFilters extends StatelessWidget {
  const ReporteStockFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, child) {
        final String tipoSeleccionado = provider.tipoStock;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                "Mostrar:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              _buildChip(
                context,
                'CALZADO',
                'Calzado',
                tipoSeleccionado,
                provider,
              ),
              const SizedBox(width: 8),
              _buildChip(
                context,
                'MATERIAL',
                'Materiales',
                tipoSeleccionado,
                provider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(
    BuildContext context,
    String value,
    String label,
    String tipoSeleccionado,
    ReporteProvider provider,
  ) {
    final bool isSelected = tipoSeleccionado == value;

    return GestureDetector(
      onTap: () {
        provider.cargarReporteStock(tipo: value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
