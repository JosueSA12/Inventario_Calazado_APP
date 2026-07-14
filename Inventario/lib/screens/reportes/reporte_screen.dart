import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/reporte_provider.dart';
import 'package:inventario/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:inventario/core/services/reporte_pdf_service.dart';
import 'package:inventario/screens/reportes/widgets/reporte_filtros.dart';
import 'package:inventario/screens/reportes/tabs/ventas_tab.dart';
import 'package:inventario/screens/reportes/tabs/produccion_tab.dart';
import 'package:inventario/screens/reportes/tabs/comparativo_tab.dart';
import 'package:inventario/screens/reportes/tabs/stock_tab.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';

class ReporteScreen extends StatefulWidget {
  const ReporteScreen({super.key});

  @override
  State<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  String _tabSeleccionada = 'ventas';
  String? _tipoFiltro;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  final List<String> _tiposFiltro = ['DIA', 'SEMANA', 'MES', 'ANIO'];

  final List<Map<String, dynamic>> _tabs = [
    {"id": "ventas", "label": "Ventas", "icon": Icons.shopping_cart_rounded},
    {"id": "produccion", "label": "Producción", "icon": Icons.factory_rounded},
    {
      "id": "comparativo",
      "label": "Comparativo",
      "icon": Icons.compare_arrows_rounded,
    },
    {"id": "stock", "label": "Stock", "icon": Icons.inventory_2_rounded},
  ];

  void _cargarPorDefecto() {
    final provider = Provider.of<ReporteProvider>(context, listen: false);
    provider.setFiltro('DIA');
    provider.setFechas(null, null);
    provider.cargarTodosLosReportes();
  }

  void _aplicarFiltroRango() {
    if (_fechaInicio == null || _fechaFin == null) {
      _mostrarError(
        'Debes seleccionar una fecha de inicio y fin para aplicar el filtro.',
      );
      return;
    }

    setState(() {
      _tipoFiltro = null;
    });

    final provider = Provider.of<ReporteProvider>(context, listen: false);
    provider.setFiltro('RANGO');
    provider.setFechas(_fechaInicio, _fechaFin);
    provider.cargarTodosLosReportes();

    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
    });
  }

  void _cambiarFiltro(String? tipo) {
    final provider = Provider.of<ReporteProvider>(context, listen: false);

    setState(() {
      _tipoFiltro = tipo;
    });

    if (tipo != null) {
      setState(() {
        _fechaInicio = null;
        _fechaFin = null;
      });
      provider.setFiltro(tipo);
      provider.setFechas(null, null);
      provider.cargarTodosLosReportes();
    } else {
      provider.limpiarDatos();
    }
  }

  void _cambiarTab(String tab) {
    setState(() => _tabSeleccionada = tab);
  }

  // ==========================================
  // EXPORTAR PDF
  // ==========================================
  Future<void> _exportarPDF() async {
    final provider = Provider.of<ReporteProvider>(context, listen: false);

    if (_tipoFiltro == null && (_fechaInicio == null || _fechaFin == null)) {
      final hasData =
          provider.ventasData != null ||
          provider.produccionData != null ||
          provider.comparativoData != null ||
          provider.stockData != null;

      if (!hasData) {
        _mostrarError('Primero debes aplicar un filtro para generar el PDF.');
        return;
      }
    }

    final String nombreFiltro = _tipoFiltro != null
        ? _getNombreFiltro(_tipoFiltro!)
        : 'Rango Personalizado';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generando PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      Uint8List pdfBytes;
      String nombreArchivo;

      switch (_tabSeleccionada) {
        case 'ventas':
          final data = provider.ventasData;
          if (data == null || data['data'] == null) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            _mostrarError('No hay datos de ventas para exportar.');
            return;
          }
          pdfBytes = await ReportePDFService.generarPDFVentas(
            data['data'] ?? {},
            filtro: nombreFiltro,
          );
          nombreArchivo =
              'Reporte_Ventas_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
          break;

        case 'produccion':
          final data = provider.produccionData;
          if (data == null || data['data'] == null) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            _mostrarError('No hay datos de producción para exportar.');
            return;
          }
          pdfBytes = await ReportePDFService.generarPDFProduccion(
            data['data'] ?? {},
          );
          nombreArchivo =
              'Reporte_Produccion_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
          break;

        case 'comparativo':
          final data = provider.comparativoData;
          if (data == null || data['data'] == null) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            _mostrarError('No hay datos comparativos para exportar.');
            return;
          }
          final listaItems = data['data'] is List ? data['data'] : [];
          pdfBytes = await ReportePDFService.generarPDFComparativo(listaItems);
          nombreArchivo =
              'Reporte_Comparativo_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
          break;

        case 'stock':
          final data = provider.stockData;
          if (data == null || data['data'] == null) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            _mostrarError('No hay datos de stock para exportar.');
            return;
          }
          final listaItems = data['data'] is List ? data['data'] : [];
          pdfBytes = await ReportePDFService.generarPDFStock(listaItems);
          nombreArchivo =
              'Reporte_Stock_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
          break;

        default:
          if (Navigator.canPop(context)) Navigator.pop(context);
          return;
      }

      if (Navigator.canPop(context)) Navigator.pop(context);
      await Printing.sharePdf(bytes: pdfBytes, filename: nombreArchivo);
      _mostrarExito('PDF generado correctamente ($nombreFiltro)');
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _mostrarError('Error al generar PDF: $e');
    }
  }

  String _getNombreFiltro(String tipo) {
    switch (tipo) {
      case 'DIA':
        return 'Hoy';
      case 'SEMANA':
        return 'Semana';
      case 'MES':
        return 'Mes';
      case 'ANIO':
        return 'Año';
      case 'RANGO':
        return 'Rango Personalizado';
      default:
        return tipo;
    }
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              ReporteFiltros(
                tipoFiltro: _tipoFiltro,
                fechaInicio: _fechaInicio,
                fechaFin: _fechaFin,
                tiposFiltro: _tiposFiltro,
                onTipoChanged: _cambiarFiltro,
                onFechaInicioChanged: (date) =>
                    setState(() => _fechaInicio = date),
                onFechaFinChanged: (date) => setState(() => _fechaFin = date),
                onAplicar: _aplicarFiltroRango,
                onCargarPorDefecto: _cargarPorDefecto,
              ),
              _buildTabs(),
              Expanded(child: _buildTabContent()),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _exportarPDF,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('PDF'),
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TABS
  // ==========================================
  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _tabs.map((tab) {
          final bool selected = _tabSeleccionada == tab["id"];
          return Expanded(
            child: InkWell(
              onTap: () => _cambiarTab(tab["id"]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? Colors.blue.shade700
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab["icon"],
                      color: selected
                          ? Colors.blue.shade700
                          : Colors.grey.shade500,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab["label"],
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? Colors.blue.shade700
                            : Colors.grey.shade500,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // CONTENIDO DE TABS
  // ==========================================
  Widget _buildTabContent() {
    switch (_tabSeleccionada) {
      case 'ventas':
        return const VentasTab();
      case 'produccion':
        return const ProduccionTab();
      case 'comparativo':
        return const ComparativoTab();
      case 'stock':
        return const StockTab();
      default:
        return const SizedBox();
    }
  }
}
