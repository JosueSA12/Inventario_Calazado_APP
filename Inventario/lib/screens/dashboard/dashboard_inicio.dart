import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/core/widgets/card_error.dart";
import "package:inventario/core/widgets/detalle_movimiento_sheet.dart";
import "package:inventario/core/widgets/shimmer_loading.dart";
import "package:inventario/core/widgets/kpi/kpi_simple.dart";
import "package:inventario/core/widgets/kpi/kpi_cantidad.dart";
import "package:inventario/core/widgets/kpi/kpi_venta.dart";
import "package:inventario/core/widgets/kpi/kpi_material.dart";
import "package:inventario/core/utils/formatters.dart";
import "package:inventario/core/services/notification_service.dart";
import "package:inventario/core/providers/dashboard_provider.dart";
import "package:inventario/models/actividad_item.dart";
import "package:inventario/screens/dashboard/widget/actividad_item_widget.dart";
import 'package:inventario/core/widgets/detalle_venta_sheet.dart';
import 'package:inventario/core/widgets/detalle_produccion_sheet.dart';
import "package:provider/provider.dart";

class DashboardInicio extends StatefulWidget {
  const DashboardInicio({super.key});

  @override
  State<DashboardInicio> createState() => _DashboardInicioState();
}

class _DashboardInicioState extends State<DashboardInicio> {
  final String baseUrl = "http://192.168.100.122:3000/api/dashboard";
  late Future<Map<String, dynamic>> _kpisFiltroFuture;

  String _filtroActual = "VENTA";
  static const _filtrosDisponibles = [
    "VENTA",
    "PRODUCCION",
    "ABASTECIMIENTO",
    "CONSUMO",
    "DESCARTE",
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _kpisFiltroFuture = _fetchKPIsFiltro(_filtroActual);
    });
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.cargarActividad(filtro: _filtroActual);
  }

  Future<Map<String, dynamic>> _fetchKPIsFiltro(String filtro) async {
    try {
      final url = "$baseUrl/kpis-filtro?tipo=$filtro";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception("Error en el servidor");
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: _buildAppBar(),
    body: _buildBody(),
  );

  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text(
      "Panel de Control",
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
  );

  Widget _buildBody() => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            "RESUMEN DEL TALLER",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          _buildKPIsDinamicos(),
          const SizedBox(height: 20),
          _buildSeccionTitulo(),
          const SizedBox(height: 12),
          _buildFiltros(),
          const SizedBox(height: 12),
          Expanded(child: _buildListaMovimientos()),
        ],
      ),
    ),
  );

  Widget _buildKPIsDinamicos() => FutureBuilder<Map<String, dynamic>>(
    future: _kpisFiltroFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const ShimmerLoadingKpis();
      }
      if (snapshot.hasError) {
        return CardError(
          mensaje: "Error KPIs: ${snapshot.error}",
          onRetry: () {
            if (mounted) _cargarDatos();
          },
        );
      }
      return _buildKPIsPorFiltro(snapshot.data!, _filtroActual);
    },
  );

  Widget _buildKPIsPorFiltro(Map<String, dynamic> kpis, String filtro) {
    final configs = _getKPiConfigs(kpis);
    final items = configs[filtro] ?? [];

    if (items.isEmpty) return const SizedBox.shrink();
    if (kpis["AlertasCriticas"] != null && kpis["AlertasCriticas"] > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          NotificationService.instance.advertencia(
            context,
            'Hay ${kpis["AlertasCriticas"]} materiales con stock bajo',
          );
        }
      });
    }

    if (filtro == "VENTA") {
      final primeros = items.take(2).toList();
      final resto = items.skip(2).toList();

      return Column(
        children: [
          Row(
            children: primeros
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildKPIWidget(item, kpis),
                    ),
                  ),
                )
                .toList(),
          ),
          if (resto.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...resto.map((item) => _buildKPIWidget(item, kpis)),
          ],
        ],
      );
    }

    if (filtro == "CONSUMO") {
      final primeros = items.take(1).toList();
      final resto = items.skip(1).toList();

      return Column(
        children: [
          Row(
            children: primeros
                .map((item) => Expanded(child: _buildKPIWidget(item, kpis)))
                .toList(),
          ),
          if (resto.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...resto.map((item) => _buildKPIWidget(item, kpis)),
          ],
        ],
      );
    }

    return Row(children: [Expanded(child: _buildKPIWidget(items.first, kpis))]);
  }

  Widget _buildKPIWidget(Map<String, dynamic> item, Map<String, dynamic> kpis) {
    final tipo = item["tipo"] as String;
    final titulo = item["titulo"] as String;
    final color = item["color"] as Color;
    final icono = item["icono"] as IconData;

    if (tipo == "detalle_venta") {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: KPIDetalleVenta(
          titulo: titulo,
          icono: icono,
          valor: kpis["ProductoMasVendido"] ?? "",
          color: color,
        ),
      );
    }

    if (tipo == "detalle_material") {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: KPIDetalleMaterial(
          titulo: titulo,
          icono: icono,
          valor: kpis["MaterialMasConsumido"] ?? "",
          color: color,
        ),
      );
    }

    final campo = item["campo"] as String;
    final valor = FormatterUtils.getNumericValue(kpis[campo]);

    if (tipo == "cantidad_derecha") {
      return KPICantidad(
        titulo: titulo,
        icono: icono,
        valor: valor,
        color: color,
      );
    }

    return KPISimple(titulo: titulo, icono: icono, valor: valor, color: color);
  }

  Map<String, List<Map<String, dynamic>>> _getKPiConfigs(
    Map<String, dynamic> kpis,
  ) {
    return {
      "VENTA": [
        {
          "tipo": "simple",
          "titulo": "Ingresos Hoy",
          "icono": Icons.savings_rounded,
          "campo": "IngresosTotales",
          "color": Colors.green.shade700,
        },
        {
          "tipo": "simple",
          "titulo": "Ventas Hoy",
          "icono": Icons.shopping_cart_rounded,
          "campo": "TotalCalzado",
          "color": Colors.blue.shade700,
        },
        if (kpis["ProductoMasVendido"] != null &&
            kpis["ProductoMasVendido"] != "")
          {
            "tipo": "detalle_venta",
            "titulo": "Mas Vendido",
            "icono": Icons.emoji_events_rounded,
            "color": Colors.amber.shade700,
          },
      ],
      "PRODUCCION": [
        {
          "tipo": "cantidad_derecha",
          "titulo": "Produccion Hoy",
          "icono": Icons.factory_rounded,
          "campo": "TotalCalzado",
          "color": Colors.purple.shade700,
        },
      ],
      "ABASTECIMIENTO": [
        {
          "tipo": "cantidad_derecha",
          "titulo": "Abastecimiento",
          "icono": Icons.handshake_rounded,
          "campo": "TotalAbastecimiento",
          "color": Colors.cyan.shade700,
        },
      ],
      "CONSUMO": [
        {
          "tipo": "cantidad_derecha",
          "titulo": "Consumo Hoy",
          "icono": Icons.build_rounded,
          "campo": "TotalMovimientos",
          "color": Colors.orange.shade700,
        },
        if (kpis["MaterialMasConsumido"] != null &&
            kpis["MaterialMasConsumido"] != "")
          {
            "tipo": "detalle_material",
            "titulo": "Mas Consumido",
            "icono": Icons.trending_up_rounded,
            "color": Colors.teal.shade700,
          },
      ],
      "DESCARTE": [
        {
          "tipo": "cantidad_derecha",
          "titulo": "Descarte Hoy",
          "icono": Icons.delete_rounded,
          "campo": "TotalDescarte",
          "color": Colors.red.shade700,
        },
      ],
    };
  }

  Widget _buildSeccionTitulo() {
    // Título dinámico según el filtro
    String titulo = "Ultimos Movimientos";
    switch (_filtroActual) {
      case "VENTA":
        titulo = "Ultimas Ventas";
        break;
      case "PRODUCCION":
        titulo = "Ultimas Producciones";
        break;
      case "ABASTECIMIENTO":
        titulo = "Ultimos Abastecimientos";
        break;
      case "CONSUMO":
        titulo = "Ultimos Consumos";
        break;
      case "DESCARTE":
        titulo = "Ultimos Descartos";
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Recientes",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              color: AppColors.primary,
              onPressed: () {
                _cargarDatos();
                final provider = Provider.of<DashboardProvider>(
                  context,
                  listen: false,
                );
                provider.cargarActividad(filtro: _filtroActual);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltros() => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _filtrosDisponibles.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final filtro = _filtrosDisponibles[index];
        final isSelected = _filtroActual == filtro;
        return _buildFiltroChip(filtro, isSelected);
      },
    ),
  );

  Widget _buildFiltroChip(String filtro, bool isSelected) {
    const colores = {
      "VENTA": Colors.green,
      "PRODUCCION": Colors.purple,
      "ABASTECIMIENTO": Colors.blue,
      "CONSUMO": Colors.orange,
      "DESCARTE": Colors.red,
    };
    const iconos = {
      "VENTA": Icons.monetization_on_rounded,
      "PRODUCCION": Icons.factory_rounded,
      "ABASTECIMIENTO": Icons.input_rounded,
      "CONSUMO": Icons.build_rounded,
      "DESCARTE": Icons.delete_rounded,
    };
    final color = colores[filtro] ?? Colors.grey;
    final icono = iconos[filtro] ?? Icons.circle;

    return GestureDetector(
      onTap: () => _cambiarFiltro(filtro),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              filtro == "VENTA"
                  ? "Ventas"
                  : filtro == "PRODUCCION"
                  ? "Produccion"
                  : filtro == "ABASTECIMIENTO"
                  ? "Abastecimiento"
                  : filtro == "CONSUMO"
                  ? "Consumo"
                  : "Descarte",
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cambiarFiltro(String filtro) {
    if (_filtroActual == filtro) return;
    setState(() {
      _filtroActual = filtro;
      _kpisFiltroFuture = _fetchKPIsFiltro(filtro);
    });

    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.cargarActividad(filtro: filtro);
  }

  Widget _buildListaMovimientos() => Consumer<DashboardProvider>(
    builder: (context, provider, child) {
      if (provider.cargando) {
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        );
      }

      if (provider.error.isNotEmpty) {
        return CardError(
          mensaje: "Error: ${provider.error}",
          onRetry: () => provider.cargarActividad(filtro: _filtroActual),
        );
      }

      final movimientos = provider.actividad;
      if (movimientos.isEmpty) {
        return const Center(
          child: Text(
            "No hay movimientos para este filtro.",
            style: TextStyle(color: AppColors.textLight, fontSize: 15),
          ),
        );
      }

      return ListView.separated(
        itemCount: movimientos.length,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => ActividadItemWidget(
          item: movimientos[index],
          onTap: () => _mostrarDetalle(context, movimientos[index]),
        ),
      );
    },
  );

  void _mostrarDetalle(BuildContext context, ActividadItem item) async {
    try {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      final detalle = await provider.obtenerDetalle(item);

      if (detalle['tipo'] == 'VENTA') {
        if (context.mounted) {
          final ventaData =
              detalle['data']['data']['venta'] as Map<String, dynamic>;
          final itemsRaw = detalle['data']['data']['items'] as List? ?? [];
          final List<Map<String, dynamic>> items = itemsRaw
              .whereType<Map<String, dynamic>>()
              .toList();

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DetalleVentaSheet(venta: ventaData, items: items),
          );
        }
      } else if (detalle['tipo'] == 'PRODUCCION') {
        if (context.mounted) {
          final ordenData =
              detalle['data']['data']['orden'] as Map<String, dynamic>;
          final materialesRaw =
              detalle['data']['data']['materiales'] as List? ?? [];
          final List<Map<String, dynamic>> materiales = materialesRaw
              .whereType<Map<String, dynamic>>()
              .toList();

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DetalleProduccionSheet(
              orden: ordenData,
              materiales: materiales,
            ),
          );
        }
      } else {
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DetalleMovimientoSheet(
              fecha: item.fecha.toIso8601String(),
              tipo: item.tipo,
              descripcion: item.descripcion,
              cantidad: item.cantidad,
              movimiento: item.movimiento,
              encargado: item.encargado,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DetalleMovimientoSheet(
            fecha: item.fecha.toIso8601String(),
            tipo: item.tipo,
            descripcion: item.descripcion,
            cantidad: item.cantidad,
            movimiento: item.movimiento,
            encargado: item.encargado,
          ),
        );
      }
    }
  }
}
