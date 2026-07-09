import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/core/widgets/tarjeta_kpi.dart';
import 'package:inventario/core/widgets/card_error.dart';
import 'package:inventario/core/widgets/shimmer_loading.dart';
import 'package:inventario/core/widgets/detalle_material_sheet.dart';

class DashboardInicio extends StatefulWidget {
  const DashboardInicio({super.key});

  @override
  State<DashboardInicio> createState() => _DashboardInicioState();
}

class _DashboardInicioState extends State<DashboardInicio> {
  final String urlResumen = 'http://10.0.2.2:3000/api/dashboard/resumen';
  final String urlActividad = 'http://10.0.2.2:3000/api/dashboard/actividad';

  late Future<Map<String, dynamic>> _resumenFuture;
  late Future<List<dynamic>> _actividadFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    _resumenFuture = obtenerResumen();
    _actividadFuture = obtenerActividad();
  }

  // Función para obtener el resumen desde la API
  Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      final response = await http.get(Uri.parse(urlResumen));
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Fallo en el servidor');
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }

  //Funcion para obtener la actividad desde la API
  Future<List<dynamic>> obtenerActividad() async {
    try {
      final response = await http.get(Uri.parse(urlActividad));
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Fallo en el servidor');
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Panel de Control',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, size: 28),
            color: AppColors.primary,
            onPressed: () => setState(() => _cargarDatos()),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'RESUMEN DEL TALLER',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // KPIs
              FutureBuilder<Map<String, dynamic>>(
                future: _resumenFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ShimmerLoadingKpis();
                  } else if (snapshot.hasError) {
                    return CardError(mensaje: 'Error KPIs: ${snapshot.error}');
                  }

                  final kpis = snapshot.data;
                  return Row(
                    children: [
                      Expanded(
                        child: TarjetaKpi(
                          titulo: 'Modelos',
                          valor: kpis?['TotalModelos']?.toString() ?? '0',
                          color: AppColors.kpiModelos,
                          icono: Icons.layers_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TarjetaKpi(
                          titulo: 'Insumos',
                          valor: kpis?['TotalMateriales']?.toString() ?? '0',
                          color: AppColors.kpiInsumos,
                          icono: Icons.handyman_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TarjetaKpi(
                          titulo: 'Alertas',
                          valor: kpis?['AlertasCriticas']?.toString() ?? '0',
                          color: AppColors.kpiAlertas,
                          icono: Icons.error_outline_rounded,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Título de movimientos
              _buildSeccionTitulo(),

              const SizedBox(height: 16),

              // Lista de movimientos
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _actividadFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return CardError(
                        mensaje: 'Error Historial: ${snapshot.error}',
                      );
                    }

                    final movimientos = snapshot.data!;
                    if (movimientos.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay movimientos recientes.',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: movimientos.length,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildItemMovimiento(context, movimientos[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionTitulo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Últimos Movimientos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'Recientes',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Construye la tarjeta de cada movimiento del historial
  Widget _buildItemMovimiento(BuildContext context, dynamic item) {
    final bool esMaterial = item['Tipo'] == 'Material';

    final String movimientoTexto = (item['Movimiento'] ?? '')
        .toString()
        .toLowerCase();

    // Identificación precisa del tipo de movimiento
    final bool esVenta = movimientoTexto.contains('venta');
    final bool esEliminado =
        movimientoTexto.contains('eliminado') ||
        movimientoTexto.contains('descarte');
    final bool esConsumoTaller =
        movimientoTexto.contains('consumo') ||
        movimientoTexto.contains('taller');
    final bool esIngresoOAbastecimiento =
        movimientoTexto.contains('ingreso') ||
        movimientoTexto.contains('abastecimiento') ||
        movimientoTexto.contains('compra');
    final bool esProduccionTerminada =
        movimientoTexto.contains('producción') ||
        movimientoTexto.contains('terminad');

    // ICONO
    IconData iconoLeading;
    Color colorIcono;
    Color colorFondoIcono;

    //ASIGNACIÓN DE ICONO
    if (esVenta) {
      iconoLeading = Icons.monetization_on_rounded;
      colorIcono = const Color(0xFF2E7D32);
      colorFondoIcono = const Color(0xFFE8F5E9);
    } else if (esEliminado) {
      iconoLeading = Icons.delete_forever_rounded;
      colorIcono = const Color(0xFFC62828);
      colorFondoIcono = const Color(0xFFFFEBEE);
    } else if (esConsumoTaller) {
      iconoLeading = Icons.build_circle_rounded;
      colorIcono = const Color(0xFFEF6C00);
      colorFondoIcono = const Color(0xFFFFF3E0);
    } else if (esIngresoOAbastecimiento) {
      iconoLeading = Icons.input_rounded;
      colorIcono = const Color(0xFF1565C0);
      colorFondoIcono = const Color(0xFFE3F2FD);
    } else if (esProduccionTerminada) {
      iconoLeading = Icons.check_circle_rounded;
      colorIcono = const Color(0xFF6A1B9A);
      colorFondoIcono = const Color(0xFFF3E5F5);
    } else {
      iconoLeading = esMaterial
          ? Icons.inventory_2_rounded
          : Icons.style_rounded;
      colorIcono = Colors.grey.shade700;
      colorFondoIcono = Colors.grey.shade200;
    }

    Color colorFondoBadge;
    Color colorTextoBadge;

    if (esVenta) {
      colorFondoBadge = const Color(0xFFE8F5E9);
      colorTextoBadge = const Color(0xFF2E7D32);
    } else if (esEliminado || movimientoTexto.contains('salida')) {
      colorFondoBadge = AppColors.salidaFondo;
      colorTextoBadge = AppColors.salidaTexto;
    } else {
      colorFondoBadge = AppColors.entradaFondo;
      colorTextoBadge = AppColors.entradaTexto;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DetalleMovimientoSheet(
              fecha: item['Fecha']?.toString() ?? '',
              tipo: item['Tipo']?.toString() ?? '',
              descripcion: item['Descripcion']?.toString() ?? '',
              cantidad: item['Cantidad']?.toString() ?? '0',
              movimiento: item['Movimiento']?.toString() ?? '',
              encargado: item['Encargado']?.toString() ?? '',
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorFondoIcono,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconoLeading, color: colorIcono, size: 24),
              ),
              const SizedBox(width: 14),

              // 2. TEXTOS EN COLUMNA (Centro)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['Descripcion'] ?? 'Sin descripción',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textDark,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${item['Movimiento']} • ${item['Encargado']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // (Derecha)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorFondoBadge,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['Cantidad']?.toString() ?? '0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: colorTextoBadge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
