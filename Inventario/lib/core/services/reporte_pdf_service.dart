import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class ReportePDFService {
  static const PdfColor _primaryColor = PdfColor(0.0, 0.45, 0.75);
  static const PdfColor _textColor = PdfColor(0.2, 0.2, 0.2);
  static const PdfColor _textLightColor = PdfColor(0.5, 0.5, 0.5);

  // ==========================================
  // GENERAR PDF DE VENTAS (CON FILTRO)
  // ==========================================
  static Future<Uint8List> generarPDFVentas(
    Map<String, dynamic> data, {
    String filtro = 'General',
  }) async {
    final pdf = pw.Document();

    final resumen = data['resumen'] ?? {};
    final ventasPorDia = data['ventasPorDia'] is List
        ? data['ventasPorDia']
        : [];
    final topProductos = data['topProductos'] is List
        ? data['topProductos']
        : [];
    final ventasPorTipo = data['ventasPorTipo'] is List
        ? data['ventasPorTipo']
        : [];

    final String tituloTabla = _getTituloTabla(filtro);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            _buildHeader('Reporte de Ventas', filtro),
            _buildResumenVentas(resumen),
            _buildTablaVentasPorDia(ventasPorDia, tituloTabla),
            _buildTablaTopProductos(topProductos),
            _buildTablaVentasPorTipo(ventasPorTipo),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // GENERAR PDF DE PRODUCCIÓN (CON FILTRO)
  // ==========================================
  static Future<Uint8List> generarPDFProduccion(
    Map<String, dynamic> data, {
    String filtro = 'General',
  }) async {
    final pdf = pw.Document();

    final resumen = data['resumen'] ?? {};
    final topModelos = data['topModelos'] is List ? data['topModelos'] : [];
    final produccionPorDia = data['produccionPorDia'] is List
        ? data['produccionPorDia']
        : [];
    final consumoMateriales = data['consumoMateriales'] is List
        ? data['consumoMateriales']
        : [];

    final String tituloTabla = _getTituloTabla(filtro);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            _buildHeader('Reporte de Producción', filtro),
            _buildResumenProduccion(resumen),
            _buildTablaProduccionPorDia(produccionPorDia, tituloTabla),
            _buildTablaTopModelos(topModelos),
            _buildTablaConsumoMateriales(consumoMateriales),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // GENERAR PDF COMPARATIVO
  // ==========================================
  static Future<Uint8List> generarPDFComparativo(
    List<dynamic> data, {
    String filtro = 'General',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            _buildHeader('Reporte Comparativo Ventas vs Producción', filtro),
            _buildTablaComparativo(data),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // GENERAR PDF DE STOCK
  // ==========================================
  static Future<Uint8List> generarPDFStock(
    List<dynamic> data, {
    String filtro = 'General',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            _buildHeader('Reporte de Stock', filtro),
            _buildTablaStock(data),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // GENERAR PDF DE VENTAS DETALLADO
  // ==========================================
  static Future<Uint8List> generarPDFVentasDetalle(
    List<dynamic> data, {
    String filtro = 'General',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            _buildHeader('Detalle de Ventas', filtro),
            _buildTablaVentasDetalle(data),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // GENERAR PDF DE PRODUCCIÓN DETALLADO
  // ==========================================
  static Future<Uint8List> generarPDFProduccionDetalle(
    Map<String, dynamic> data, {
    String filtro = 'General',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            _buildHeader('Detalle de Producción', filtro),
            _buildTablaProduccionDetalle(data['cabecera'] ?? []),
            _buildTablaMaterialesConsumidos(data['materiales'] ?? []),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // MÉTODOS PRIVADOS
  // ==========================================
  static String _getTituloTabla(String filtro) {
    switch (filtro) {
      case 'Hoy':
        return 'Ventas de Hoy';
      case 'Semana':
        return 'Ventas por Día (Última Semana)';
      case 'Mes':
        return 'Ventas por Día (Último Mes)';
      case 'Año':
        return 'Ventas por Mes (Último Año)';
      case 'Rango Personalizado':
        return 'Ventas en Rango de Fechas';
      default:
        return 'Ventas por Día';
    }
  }

  static pw.Widget _buildHeader(String titulo, String filtro) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'Taller de Calzado',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            '$titulo - Filtro: $filtro',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
        ),
        pw.Center(
          child: pw.Text(
            'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: _textLightColor),
          ),
        ),
        pw.Divider(thickness: 1, color: _primaryColor),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildResumenVentas(Map<String, dynamic> resumen) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumen de Ventas',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            _buildInfoCard('Total Ventas', '${resumen['TotalVentas'] ?? 0}'),
            _buildInfoCard(
              'Pares Vendidos',
              '${resumen['TotalParesVendidos'] ?? 0}',
            ),
            _buildInfoCard(
              'Total Ingresos',
              'S/. ${(resumen['TotalIngresos'] ?? 0.0).toStringAsFixed(2)}',
            ),
            _buildInfoCard(
              'Promedio',
              'S/. ${(resumen['PromedioPorVenta'] ?? 0.0).toStringAsFixed(2)}',
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildResumenProduccion(Map<String, dynamic> resumen) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumen de Producción',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            _buildInfoCard('Total Órdenes', '${resumen['TotalOrdenes'] ?? 0}'),
            _buildInfoCard(
              'Pares Producidos',
              '${resumen['TotalParesProducidos'] ?? 0}',
            ),
            _buildInfoCard(
              'Promedio por Orden',
              '${(resumen['PromedioParesPorOrden'] ?? 0.0).toStringAsFixed(1)}',
            ),
            _buildInfoCard('Modelos', '${resumen['ModelosProducidos'] ?? 0}'),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildInfoCard(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.all(2),
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8, color: _textLightColor),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Tabla con título dinámico
  static pw.Widget _buildTablaVentasPorDia(List<dynamic> data, String titulo) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titulo,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('Fecha'),
                _buildTableHeader('N° Ventas'),
                _buildTableHeader('Pares Vendidos'),
                _buildTableHeader('Ingresos'),
              ],
            ),
            ...data.map(
              (item) => pw.TableRow(
                children: [
                  _buildTableCell(item['Fecha']?.substring(0, 10) ?? ''),
                  _buildTableCell('${item['NumeroVentas'] ?? 0}'),
                  _buildTableCell('${item['ParesVendidos'] ?? 0}'),
                  _buildTableCell(
                    'S/. ${(item['IngresosDelDia'] ?? 0.0).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  // ✅ Tabla de producción con título dinámico
  static pw.Widget _buildTablaProduccionPorDia(
    List<dynamic> data,
    String titulo,
  ) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titulo.replaceAll('Ventas', 'Producción'),
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('Fecha'),
                _buildTableHeader('N° Órdenes'),
                _buildTableHeader('Pares Producidos'),
              ],
            ),
            ...data.map(
              (item) => pw.TableRow(
                children: [
                  _buildTableCell(item['Fecha']?.substring(0, 10) ?? ''),
                  _buildTableCell('${item['NumeroOrdenes'] ?? 0}'),
                  _buildTableCell('${item['ParesProducidos'] ?? 0}'),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  // ... (el resto de las tablas _buildTablaTopProductos, _buildTablaVentasPorTipo, etc. permanecen igual)

  static pw.Widget _buildTablaTopProductos(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Top 5 Productos Más Vendidos',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('N°'),
                _buildTableHeader('Modelo'),
                _buildTableHeader('Tipo'),
                _buildTableHeader('Talla'),
                _buildTableHeader('Vendidos'),
                _buildTableHeader('Ingresos'),
              ],
            ),
            ...data.map(
              (item) => pw.TableRow(
                children: [
                  _buildTableCell('${data.indexOf(item) + 1}'),
                  _buildTableCell(item['Modelo'] ?? ''),
                  _buildTableCell(item['Tipo'] ?? ''),
                  _buildTableCell('${item['Talla'] ?? ''}'),
                  _buildTableCell('${item['TotalVendido'] ?? 0}'),
                  _buildTableCell(
                    'S/. ${(item['TotalIngresado'] ?? 0.0).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTablaVentasPorTipo(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Ventas por Tipo de Calzado',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('Tipo'),
                _buildTableHeader('N° Ventas'),
                _buildTableHeader('Pares Vendidos'),
                _buildTableHeader('Ingresos'),
              ],
            ),
            ...data.map(
              (item) => pw.TableRow(
                children: [
                  _buildTableCell(item['TipoCalzado'] ?? ''),
                  _buildTableCell('${item['NumeroVentas'] ?? 0}'),
                  _buildTableCell('${item['ParesVendidos'] ?? 0}'),
                  _buildTableCell(
                    'S/. ${(item['IngresosTotales'] ?? 0.0).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTablaTopModelos(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Top 5 Modelos Más Producidos',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('N°'),
                _buildTableHeader('Modelo'),
                _buildTableHeader('Tipo'),
                _buildTableHeader('Talla'),
                _buildTableHeader('Producidos'),
                _buildTableHeader('Órdenes'),
              ],
            ),
            ...data.map(
              (item) => pw.TableRow(
                children: [
                  _buildTableCell('${data.indexOf(item) + 1}'),
                  _buildTableCell(item['Modelo'] ?? ''),
                  _buildTableCell(item['Tipo'] ?? ''),
                  _buildTableCell('${item['Talla'] ?? ''}'),
                  _buildTableCell('${item['TotalProducido'] ?? 0}'),
                  _buildTableCell('${item['NumeroOrdenes'] ?? 0}'),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTablaConsumoMateriales(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Top 5 Materiales Más Consumidos',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('N°'),
                _buildTableHeader('Material'),
                _buildTableHeader('Categoría'),
                _buildTableHeader('Consumido'),
                _buildTableHeader('Unidad'),
              ],
            ),
            ...data.map(
              (item) => pw.TableRow(
                children: [
                  _buildTableCell('${data.indexOf(item) + 1}'),
                  _buildTableCell(item['Material'] ?? ''),
                  _buildTableCell(item['Categoria'] ?? ''),
                  _buildTableCell(
                    '${(item['TotalConsumido'] ?? 0.0).toStringAsFixed(1)}',
                  ),
                  _buildTableCell(item['Unidad'] ?? ''),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTablaComparativo(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Comparativa Mensual',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('Periodo'),
                _buildTableHeader('Pares Vendidos'),
                _buildTableHeader('Pares Producidos'),
                _buildTableHeader('Diferencia'),
                _buildTableHeader('Conversión'),
                _buildTableHeader('Ingresos'),
              ],
            ),
            ...data.map(
              (item) => pw.TableRow(
                children: [
                  _buildTableCell(item['Periodo'] ?? ''),
                  _buildTableCell('${item['ParesVendidos'] ?? 0}'),
                  _buildTableCell('${item['ParesProducidos'] ?? 0}'),
                  _buildTableCell('${item['DiferenciaPares'] ?? 0}'),
                  _buildTableCell(
                    '${(item['PorcentajeConversion'] ?? 0.0).toStringAsFixed(1)}%',
                  ),
                  _buildTableCell(
                    'S/. ${(item['IngresosPorVentas'] ?? 0.0).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTablaStock(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Stock Actual',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('Tipo'),
                _buildTableHeader('Nombre'),
                _buildTableHeader('Categoría'),
                _buildTableHeader('Stock'),
                _buildTableHeader('Estado'),
              ],
            ),
            ...data.map(
              (item) => pw.TableRow(
                children: [
                  _buildTableCell(item['Tipo'] ?? ''),
                  _buildTableCell(item['Nombre'] ?? ''),
                  _buildTableCell(item['Categoria'] ?? ''),
                  _buildTableCell(item['Stock'] ?? '0'),
                  _buildTableCell(item['Estado'] ?? ''),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTablaVentasDetalle(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalle de Ventas',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('ID'),
                _buildTableHeader('Fecha'),
                _buildTableHeader('Vendedor'),
                _buildTableHeader('Modelo'),
                _buildTableHeader('Cantidad'),
                _buildTableHeader('Subtotal'),
                _buildTableHeader('Total Venta'),
              ],
            ),
            ...data
                .take(20)
                .map(
                  (item) => pw.TableRow(
                    children: [
                      _buildTableCell('${item['VentaID'] ?? ''}'),
                      _buildTableCell(item['Fecha']?.substring(0, 10) ?? ''),
                      _buildTableCell(item['Vendedor'] ?? ''),
                      _buildTableCell(item['Modelo'] ?? ''),
                      _buildTableCell('${item['Cantidad'] ?? 0}'),
                      _buildTableCell(
                        'S/. ${(item['Subtotal'] ?? 0.0).toStringAsFixed(2)}',
                      ),
                      _buildTableCell(
                        'S/. ${(item['TotalVenta'] ?? 0.0).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Mostrando ${data.length > 20 ? 20 : data.length} de ${data.length} registros',
          style: pw.TextStyle(fontSize: 8, color: _textLightColor),
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTablaProduccionDetalle(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalle de Producción',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('Orden #'),
                _buildTableHeader('Fecha'),
                _buildTableHeader('Operario'),
                _buildTableHeader('Modelo'),
                _buildTableHeader('Tipo'),
                _buildTableHeader('Pares'),
              ],
            ),
            ...data
                .take(15)
                .map(
                  (item) => pw.TableRow(
                    children: [
                      _buildTableCell('${item['OrdenID'] ?? ''}'),
                      _buildTableCell(item['Fecha']?.substring(0, 10) ?? ''),
                      _buildTableCell(item['Operario'] ?? ''),
                      _buildTableCell(item['Modelo'] ?? ''),
                      _buildTableCell(item['Tipo'] ?? ''),
                      _buildTableCell('${item['ParesProducidos'] ?? 0}'),
                    ],
                  ),
                ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Mostrando ${data.length > 15 ? 15 : data.length} de ${data.length} registros',
          style: pw.TextStyle(fontSize: 8, color: _textLightColor),
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTablaMaterialesConsumidos(List<dynamic> data) {
    if (data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Materiales Consumidos',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableHeader('Orden #'),
                _buildTableHeader('Material'),
                _buildTableHeader('Cantidad'),
                _buildTableHeader('Unidad'),
              ],
            ),
            ...data
                .take(20)
                .map(
                  (item) => pw.TableRow(
                    children: [
                      _buildTableCell('${item['OrdenID'] ?? ''}'),
                      _buildTableCell(item['Material'] ?? ''),
                      _buildTableCell(
                        '${(item['Cantidad'] ?? 0.0).toStringAsFixed(1)}',
                      ),
                      _buildTableCell(item['Unidad'] ?? ''),
                    ],
                  ),
                ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Mostrando ${data.length > 20 ? 20 : data.length} de ${data.length} registros',
          style: pw.TextStyle(fontSize: 8, color: _textLightColor),
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, color: _textColor),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Sistema de Gestión de Taller de Calzado',
              style: pw.TextStyle(fontSize: 7, color: _textLightColor),
            ),
            pw.Text(
              DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
              style: pw.TextStyle(fontSize: 7, color: _textLightColor),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }
}
