import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/reporte_provider.dart';
import 'package:inventario/screens/reportes/widgets/reporte_stock_filters.dart';

class StockTab extends StatelessWidget {
  const StockTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, child) {
        if (provider.loadingStock) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = provider.stockData;
        if (data == null || data.containsKey('error')) {
          return _buildError(
            context,
            'Error al cargar datos',
            () => provider.cargarReporteStock(tipo: provider.tipoStock),
          );
        }

        List<dynamic> listaItems = [];
        if (data['data'] is List) {
          listaItems = data['data'];
        } else if (data is List) {
          listaItems = data as List<dynamic>;
        }

        if (listaItems.isEmpty) {
          return const Center(child: Text("No hay datos de stock"));
        }

        return Column(
          children: [
            const ReporteStockFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    provider.cargarReporteStock(tipo: provider.tipoStock),
                color: Colors.blue,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: listaItems.length,
                  itemBuilder: (context, index) {
                    final item = listaItems[index];
                    return _buildStockCard(item);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStockCard(Map<String, dynamic> item) {
    final estado = item['Estado'] ?? 'Stock Normal';
    final Color colorEstado = estado == 'Sin Stock'
        ? Colors.red
        : estado == 'Stock Bajo'
        ? Colors.orange
        : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item['Tipo'] == 'Calzado'
              ? Colors.blue.shade100
              : Colors.green.shade100,
          child: Icon(
            item['Tipo'] == 'Calzado'
                ? Icons.shopping_bag_rounded
                : Icons.inventory_2_rounded,
            color: item['Tipo'] == 'Calzado'
                ? Colors.blue.shade700
                : Colors.green.shade700,
          ),
        ),
        title: Text(
          item['Nombre'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${item['Categoria'] ?? ''} ${item['Color']?.isNotEmpty == true ? '• ${item['Color']}' : ''} ${item['Talla'] != 'N/A' ? '• Talla ${item['Talla']}' : ''}",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item['Stock'] ?? '0',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                estado,
                style: TextStyle(
                  fontSize: 10,
                  color: colorEstado,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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
