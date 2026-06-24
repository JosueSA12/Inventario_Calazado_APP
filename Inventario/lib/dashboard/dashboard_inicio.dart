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

  Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      final response = await http.get(Uri.parse(urlResumen));
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Fallo en el servidor');
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }

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
            icon: const Icon(Icons.refresh_rounded, size: 28),
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
            color: AppColors.primary.withOpacity(0.08),
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

    final bool esSalida = item['Movimiento'].toString().toLowerCase().contains(
      'salida',
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
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
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: esMaterial
                ? AppColors.categoriaMaterialFondo
                : AppColors.categoriaEstiloFondo,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            esMaterial ? Icons.inventory_2_rounded : Icons.style_rounded,
            color: esMaterial
                ? AppColors.categoriaMaterialIcono
                : AppColors.categoriaEstiloIcono,
            size: 24,
          ),
        ),
        title: Text(
          item['Descripcion'] ?? 'Sin descripción',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5),
        ),
        subtitle: Text('${item['Movimiento']} • ${item['Encargado']}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: esSalida ? AppColors.salidaFondo : AppColors.entradaFondo,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item['Cantidad']?.toString() ?? '0',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: esSalida ? AppColors.salidaTexto : AppColors.entradaTexto,
            ),
          ),
        ),
      ),
    );
  }
}
