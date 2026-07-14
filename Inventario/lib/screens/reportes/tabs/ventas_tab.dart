import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/reporte_provider.dart';
import 'package:inventario/screens/reportes/widgets/reporte_resumen_card.dart';
import 'package:inventario/screens/reportes/widgets/reporte_top_list.dart';
import 'package:inventario/screens/reportes/widgets/reporte_chart.dart';
import 'package:inventario/screens/reportes/widgets/reporte_pie_chart.dart';

class VentasTab extends StatelessWidget {
  const VentasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, child) {
        if (provider.loadingVentas) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = provider.ventasData;
        if (data == null || data.containsKey('error')) {
          return _buildError(
            context,
            'Error al cargar datos',
            () => provider.cargarReporteVentas(),
          );
        }

        final dataInterna = data['data'] ?? {};
        final resumen = dataInterna['resumen'] ?? {};
        final topProductos = dataInterna['topProductos'] as List? ?? [];
        final ventasPorDia = dataInterna['ventasPorDia'] as List? ?? [];
        final ventasPorTipo = dataInterna['ventasPorTipo'] as List? ?? [];

        final String tipoFiltro = provider.filtroActual ?? 'RANGO';

        final chartKey = ValueKey('${provider.version}_$tipoFiltro');

        return RefreshIndicator(
          onRefresh: () => provider.cargarReporteVentas(),
          color: Colors.blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ReporteResumenCard(
                  titulo: "Resumen de Ventas",
                  items: [
                    {
                      "label": "Total Ventas",
                      "value": resumen['TotalVentas'] ?? 0,
                      "icon": Icons.receipt_rounded,
                    },
                    {
                      "label": "Total Ingresos",
                      "value":
                          "S/. ${resumen['TotalIngresos']?.toStringAsFixed(2) ?? '0.00'}",
                      "icon": Icons.attach_money_rounded,
                    },
                    {
                      "label": "Pares Vendidos",
                      "value": resumen['TotalParesVendidos'] ?? 0,
                      "icon": Icons.shopping_bag_rounded,
                    },
                    {
                      "label": "Promedio por Venta",
                      "value":
                          "S/. ${resumen['PromedioPorVenta']?.toStringAsFixed(2) ?? '0.00'}",
                      "icon": Icons.trending_up_rounded,
                    },
                  ],
                ),
                const SizedBox(height: 16),
                ReporteChart(
                  key: chartKey,
                  items: ventasPorDia,
                  titulo: "Ventas",
                  valorKey: "ParesVendidos",
                  tipoFiltro: tipoFiltro,
                ),
                const SizedBox(height: 16),
                ReportePieChart(
                  items: ventasPorTipo,
                  titulo: "Ventas por Tipo de Calzado",
                  labelKey: "TipoCalzado",
                  valueKey: "ParesVendidos",
                ),
                const SizedBox(height: 16),
                ReporteTopList(
                  items: topProductos,
                  titulo: "Top 5 Productos Más Vendidos",
                  color: Colors.blue,
                  detallePrefijo: 'S/.',
                ),
              ],
            ),
          ),
        );
      },
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
