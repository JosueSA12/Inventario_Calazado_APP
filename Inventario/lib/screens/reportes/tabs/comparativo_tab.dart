import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/reporte_provider.dart';

class ComparativoTab extends StatelessWidget {
  const ComparativoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, child) {
        if (provider.loadingComparativo) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = provider.comparativoData;
        if (data == null || data.containsKey('error')) {
          return _buildError(
            context,
            'Error al cargar datos',
            () => provider.cargarReporteComparativo(),
          );
        }

        List<dynamic> listaItems = [];
        if (data['data'] is List) {
          listaItems = data['data'];
        } else if (data is List) {
          listaItems = data as List<dynamic>;
        }

        if (listaItems.isEmpty) {
          return const Center(child: Text("No hay datos comparativos"));
        }

        return RefreshIndicator(
          onRefresh: () => provider.cargarReporteComparativo(),
          color: Colors.purple,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Comparativa Mensual",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaItems.length,
                  itemBuilder: (context, index) {
                    final item = listaItems[index];
                    return _buildComparativoCard(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparativoCard(Map<String, dynamic> item) {
    final conversion = (item['PorcentajeConversion'] ?? 0.0).toDouble();
    final diferencia = item['DiferenciaPares'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['Periodo'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "S/. ${(item['IngresosPorVentas'] ?? 0.0).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildIndicator(
                  label: "Ventas",
                  value: item['ParesVendidos'] ?? 0,
                  color: Colors.blue,
                  icon: Icons.shopping_cart_rounded,
                ),
                const SizedBox(width: 16),
                _buildIndicator(
                  label: "Producción",
                  value: item['ParesProducidos'] ?? 0,
                  color: Colors.green,
                  icon: Icons.factory_rounded,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: conversion >= 80
                            ? Colors.green.shade100
                            : conversion >= 50
                            ? Colors.orange.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${conversion.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: conversion >= 80
                              ? Colors.green.shade700
                              : conversion >= 50
                              ? Colors.orange.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diferencia >= 0 ? "▲ +$diferencia" : "▼ $diferencia",
                      style: TextStyle(
                        fontSize: 12,
                        color: diferencia >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: conversion / 100,
              backgroundColor: Colors.grey.shade200,
              color: conversion >= 80
                  ? Colors.green
                  : conversion >= 50
                  ? Colors.orange
                  : Colors.red,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        Text(
          "$value pares",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    String mensaje,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(mensaje, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text("Reintentar")),
        ],
      ),
    );
  }
}
