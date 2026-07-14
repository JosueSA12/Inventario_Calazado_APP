import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/reporte_provider.dart';
import 'package:inventario/screens/reportes/widgets/reporte_resumen_card.dart';
import 'package:inventario/screens/reportes/widgets/reporte_top_list.dart';
import 'package:inventario/screens/reportes/widgets/reporte_chart.dart';
import 'package:inventario/screens/reportes/widgets/reporte_pie_chart.dart';

class ProduccionTab extends StatelessWidget {
  const ProduccionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, child) {
        if (provider.loadingProduccion) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = provider.produccionData;
        if (data == null || data.containsKey('error')) {
          return _buildError(
            context,
            'Error al cargar datos',
            () => provider.cargarReporteProduccion(),
          );
        }

        final dataInterna = data['data'] ?? {};
        final resumen = dataInterna['resumen'] ?? {};
        final topModelos = dataInterna['topModelos'] as List? ?? [];
        final produccionPorDia = dataInterna['produccionPorDia'] as List? ?? [];
        final consumoMateriales =
            dataInterna['consumoMateriales'] as List? ?? [];

        final String tipoFiltro = provider.filtroActual ?? 'RANGO';
        final String chartKey =
            'produccion_chart_${provider.version}_${produccionPorDia.length}_$tipoFiltro';

        return RefreshIndicator(
          onRefresh: () => provider.cargarReporteProduccion(),
          color: Colors.green,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ReporteResumenCard(
                  titulo: "Resumen de Producción",
                  items: [
                    {
                      "label": "Total Órdenes",
                      "value": resumen['TotalOrdenes'] ?? 0,
                      "icon": Icons.receipt_rounded,
                    },
                    {
                      "label": "Pares Producidos",
                      "value": resumen['TotalParesProducidos'] ?? 0,
                      "icon": Icons.factory_rounded,
                    },
                    {
                      "label": "Promedio por Orden",
                      "value":
                          resumen['PromedioParesPorOrden']?.toStringAsFixed(
                            1,
                          ) ??
                          '0.0',
                      "icon": Icons.trending_up_rounded,
                    },
                    {
                      "label": "Modelos Producidos",
                      "value": resumen['ModelosProducidos'] ?? 0,
                      "icon": Icons.style_rounded,
                    },
                  ],
                ),
                const SizedBox(height: 16),
                ReporteChart(
                  key: ValueKey(chartKey),
                  items: produccionPorDia,
                  titulo: "Producción",
                  valorKey: "ParesProducidos",
                  tipoFiltro: tipoFiltro, // PASAMOS EL FILTRO
                ),
                const SizedBox(height: 16),
                ReportePieChart(
                  items: consumoMateriales,
                  titulo: "Materiales Más Consumidos",
                  labelKey: "Material",
                  valueKey: "TotalConsumido",
                  colors: const [
                    Colors.orange,
                    Colors.amber,
                    Colors.deepOrange,
                    Colors.yellow,
                    Colors.brown,
                  ],
                ),
                const SizedBox(height: 16),
                ReporteTopList(
                  items: topModelos,
                  titulo: "Top 5 Modelos Más Producidos",
                  color: Colors.green,
                  unidad: 'pares',
                  subtituloKey: 'Color',
                  valorKey: 'TotalProducido',
                  detalleKey: 'NumeroOrdenes',
                  detallePrefijo: 'Órdenes:',
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
