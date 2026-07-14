import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/core/widgets/card_error.dart";
import "package:inventario/core/widgets/shimmer_loading.dart";
import "package:inventario/core/widgets/kpi/kpi_simple.dart";
import "package:inventario/core/widgets/kpi/kpi_cantidad.dart";
import "package:inventario/core/widgets/kpi/kpi_venta.dart";
import "package:inventario/core/widgets/kpi/kpi_material.dart";
import "package:inventario/core/widgets/detalle_movimiento_sheet.dart";
import "package:inventario/models/movimiento_config.dart";
import "package:inventario/core/utils/formatters.dart";
import "package:inventario/core/services/notification_service.dart";

class DashboardInicio extends StatefulWidget {
  const DashboardInicio({super.key});

  @override
  State<DashboardInicio> createState() => _DashboardInicioState();
}

class _DashboardInicioState extends State<DashboardInicio> {
  final String baseUrl = "http://192.168.100.122:3000/api/dashboard";
  late Future<List<dynamic>> _actividadFuture;
  late Future<Map<String, dynamic>> _kpisFiltroFuture;

  String _filtroActual = "TODOS";
  static const _filtrosDisponibles = [
    "TODOS",
    "VENTA",
    "ABASTECIMIENTO",
    "PRODUCCION",
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
      _actividadFuture = _fetchActividad(_filtroActual);
      _kpisFiltroFuture = _fetchKPIsFiltro(_filtroActual);
    });
  }

  // ==================== API ====================
  Future<List<dynamic>> _fetchActividad(String filtro) async {
    try {
      final url = filtro == "TODOS"
          ? "$baseUrl/actividad"
          : "$baseUrl/filtrar-movimientos?tipo=$filtro";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception("Error en el servidor");
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchKPIsFiltro(String filtro) async {
    try {
      final url = filtro == "TODOS"
          ? "$baseUrl/resumen"
          : "$baseUrl/kpis-filtro?tipo=$filtro";
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

  // ==================== KPIs DINÁMICOS ====================
  Widget _buildKPIsDinamicos() => FutureBuilder<Map<String, dynamic>>(
    future: _kpisFiltroFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const ShimmerLoadingKpis();
      }
      if (snapshot.hasError) {
        return CardError(
          mensaje: "Error KPIs: ${snapshot.error}",
          onRetry: _cargarDatos,
        );
      }
      return _buildKPIsPorFiltro(snapshot.data!, _filtroActual);
    },
  );

  // ==================== KPIs POR FILTRO ====================
  Widget _buildKPIsPorFiltro(Map<String, dynamic> kpis, String filtro) {
    final configs = _getKPiConfigs(kpis);
    final items = configs[filtro] ?? [];

    if (items.isEmpty) return const SizedBox.shrink();
    if (filtro == "TODOS" &&
        kpis["AlertasCriticas"] != null &&
        kpis["AlertasCriticas"] > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          NotificationService.instance.advertencia(
            context,
            'Hay ${kpis["AlertasCriticas"]} materiales con stock bajo',
          );
        }
      });
    }

    if (items.isEmpty) return const SizedBox.shrink();

    if (filtro == "TODOS") {
      return Row(
        children: items
            .map(
              (item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildKPIWidget(item, kpis),
                ),
              ),
            )
            .toList(),
      );
    }

    // ==========================================
    // FILTRO VENTA
    // ==========================================
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

    // ==========================================
    // FILTRO CONSUMO
    // ==========================================
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

    // ==========================================
    //  (PRODUCCION, ABASTECIMIENTO, DESCARTE)
    // ==========================================
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

  // ==================== CONFIGURACIÓN DE KPIs ====================
  Map<String, List<Map<String, dynamic>>> _getKPiConfigs(
    Map<String, dynamic> kpis,
  ) {
    return {
      "TODOS": [
        {
          "tipo": "simple",
          "titulo": "Modelos",
          "icono": Icons.category_rounded,
          "campo": "TotalModelos",
          "color": AppColors.kpiModelos,
        },
        {
          "tipo": "simple",
          "titulo": "Insumos",
          "icono": Icons.inventory_2_rounded,
          "campo": "TotalMateriales",
          "color": AppColors.kpiInsumos,
        },
        {
          "tipo": "simple",
          "titulo": "Alertas",
          "icono": Icons.warning_amber_rounded,
          "campo": "AlertasCriticas",
          "color": AppColors.kpiAlertas,
        },
      ],
      "VENTA": [
        {
          "tipo": "simple",
          "titulo": "Ingresos",
          "icono": Icons.savings_rounded,
          "campo": "IngresosTotales",
          "color": Colors.green.shade700,
        },
        {
          "tipo": "simple",
          "titulo": "Ventas",
          "icono": Icons.shopping_cart_rounded,
          "campo": "TotalCalzado",
          "color": Colors.blue.shade700,
        },
        if (kpis["ProductoMasVendido"] != null &&
            kpis["ProductoMasVendido"] != "")
          {
            "tipo": "detalle_venta",
            "titulo": "Más Vendido",
            "icono": Icons.emoji_events_rounded,
            "color": Colors.amber.shade700,
          },
      ],
      "PRODUCCION": [
        {
          "tipo": "cantidad_derecha",
          "titulo": "Producción",
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
          "titulo": "Consumo",
          "icono": Icons.build_rounded,
          "campo": "TotalMovimientos",
          "color": Colors.orange.shade700,
        },
        if (kpis["MaterialMasConsumido"] != null &&
            kpis["MaterialMasConsumido"] != "")
          {
            "tipo": "detalle_material",
            "titulo": "Más Consumido",
            "icono": Icons.trending_up_rounded,
            "color": Colors.teal.shade700,
          },
      ],
      "DESCARTE": [
        {
          "tipo": "cantidad_derecha",
          "titulo": "Descarte",
          "icono": Icons.delete_rounded,
          "campo": "TotalDescarte",
          "color": Colors.red.shade700,
        },
      ],
    };
  }

  // ==================== SECCIÓN TÍTULO ====================
  Widget _buildSeccionTitulo() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        "Últimos Movimientos",
        style: TextStyle(
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
            onPressed: _cargarDatos,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    ],
  );

  // ==================== FILTROS ====================
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
      "TODOS": Colors.grey,
      "VENTA": Colors.green,
      "ABASTECIMIENTO": Colors.blue,
      "PRODUCCION": Colors.purple,
      "CONSUMO": Colors.orange,
      "DESCARTE": Colors.red,
    };
    const iconos = {
      "TODOS": Icons.list_rounded,
      "VENTA": Icons.monetization_on_rounded,
      "ABASTECIMIENTO": Icons.input_rounded,
      "PRODUCCION": Icons.factory_rounded,
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
              filtro == "TODOS" ? "Todos" : filtro,
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
      _actividadFuture = _fetchActividad(filtro);
      _kpisFiltroFuture = _fetchKPIsFiltro(filtro);
    });
  }

  // ==================== LISTA DE MOVIMIENTOS ====================
  Widget _buildListaMovimientos() => FutureBuilder<List<dynamic>>(
    future: _actividadFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        );
      }
      if (snapshot.hasError) {
        return CardError(
          mensaje: "Error Historial: ${snapshot.error}",
          onRetry: _cargarDatos,
        );
      }
      final movimientos = snapshot.data!;
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
        itemBuilder: (context, index) =>
            _buildItemMovimiento(movimientos[index]),
      );
    },
  );

  // ==================== ITEM DE MOVIMIENTO ====================
  Widget _buildItemMovimiento(dynamic item) {
    final movimiento = (item["Movimiento"] ?? "").toString().toLowerCase();
    final esMaterial = item["Tipo"] == "Material";
    final config = MovimientoConfig.fromMovimiento(movimiento, esMaterial);

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
        onTap: () => _showDetalleMovimiento(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: config.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(config.icon, color: config.iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["Descripcion"] ?? "Sin descripción",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${item["Movimiento"]}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${item["Encargado"]}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: config.badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item["Cantidad"]?.toString() ?? "0",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: config.badgeText,
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

  //Metodo para mostrar el detalle del movimiento
  void _showDetalleMovimiento(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetalleMovimientoSheet(
        fecha: item["Fecha"]?.toString() ?? "",
        tipo: item["Tipo"]?.toString() ?? "",
        descripcion: item["Descripcion"]?.toString() ?? "",
        cantidad: item["Cantidad"]?.toString() ?? "0",
        movimiento: item["Movimiento"]?.toString() ?? "",
        encargado: item["Encargado"]?.toString() ?? "",
      ),
    );
  }
}
