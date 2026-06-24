import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inventario/widgets/detalles_view.dart';

// ===========================
// 1. CLASE DE MODELO
// ===========================
class AlertaMaterial {
  final String codigo;
  final String insumo;
  final String categoria;
  final double cantidad;
  final String medida;
  final String proveedor;

  const AlertaMaterial({
    required this.codigo,
    required this.insumo,
    required this.categoria,
    required this.cantidad,
    required this.medida,
    required this.proveedor,
  });

  factory AlertaMaterial.fromJson(Map<String, dynamic> json) {
    return AlertaMaterial(
      codigo: json['codigo']?.toString() ?? '',
      insumo: json['insumo']?.toString() ?? 'Sin nombre',
      categoria: json['categoria']?.toString() ?? 'General',
      cantidad: (json['cantidad'] as num?)?.toDouble() ?? 0.0,
      medida: json['medida']?.toString() ?? '',
      proveedor: json['proveedor']?.toString() ?? 'Sin Proveedor',
    );
  }
}

// ====================
// VISTA PRINCIPAL
// ====================
class AlertasStockView extends StatefulWidget {
  const AlertasStockView({super.key});

  @override
  State<AlertasStockView> createState() => _AlertasStockViewState();
}

class _AlertasStockViewState extends State<AlertasStockView> {
  final String urlAlertas = 'http://10.0.2.2:3000/api/materiales/alertas';
  late Future<List<AlertaMaterial>> _alertasFuture;

  // Paleta de colores Premium alineada al Taller
  static const Color dangerColor = Color(0xFFDC2626);
  static const Color backgroundColor = Color(0xFFFDFBF9);
  static const Color surfaceColor = Colors.white;
  static const Color textDark = Color(0xFF2C2520);
  static const Color textLight = Color(0xFF7A726C);

  @override
  void initState() {
    super.initState();
    _refrescarAlertas();
  }

  void _refrescarAlertas() {
    setState(() {
      _alertasFuture = obtenerAlertas();
    });
  }

  Future<List<AlertaMaterial>> obtenerAlertas() async {
    try {
      final response = await http
          .get(Uri.parse(urlAlertas))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AlertaMaterial.fromJson(json)).toList();
      }
      throw Exception('Error del servidor (${response.statusCode})');
    } catch (e) {
      throw Exception('No se pudo conectar al taller. Verifica tu red.');
    }
  }

  // Abre el detalle
  void _mostrarDetalleMaterial(BuildContext context, AlertaMaterial material) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DetalleBajoStockSheet(
        codigo: material.codigo,
        insumo: material.insumo,
        categoria: material.categoria,
        cantidad: material.cantidad,
        medida: material.medida,
        proveedor: material.proveedor,
        onOrdenarMas: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: dangerColor),
            SizedBox(width: 8),
            Text(
              'Alertas de Abastecimiento',
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4A3423)),
            onPressed: _refrescarAlertas,
          ),
        ],
      ),
      body: FutureBuilder<List<AlertaMaterial>>(
        future: _alertasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: dangerColor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: dangerColor,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}'.replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: textDark, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refrescarAlertas,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final alertas = snapshot.data ?? [];

          if (alertas.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            color: dangerColor,
            onRefresh: () async => _refrescarAlertas(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: alertas.length,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final material = alertas[index];
                return _AlertaCard(
                  material: material,
                  onTap: () => _mostrarDetalleMaterial(context, material),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==================================
// TARJETA DE ALERTA INDIVIDUAL
// ===================================
class _AlertaCard extends StatelessWidget {
  final AlertaMaterial material;
  final VoidCallback onTap;

  const _AlertaCard({required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _AlertasStockViewState.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _AlertasStockViewState.dangerColor.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _AlertasStockViewState.dangerColor.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _AlertasStockViewState.dangerColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_down_rounded,
                    color: _AlertasStockViewState.dangerColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.insumo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _AlertasStockViewState.textDark,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prov: ${material.proveedor}\nCategoría: ${material.categoria}',
                        style: const TextStyle(
                          color: _AlertasStockViewState.textLight,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${material.cantidad}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _AlertasStockViewState.dangerColor,
                      ),
                    ),
                    if (material.medida.isNotEmpty)
                      Text(
                        material.medida,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _AlertasStockViewState.dangerColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================
//ESTADO VACÍO
// =====================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: Colors.green.shade500,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Todo en orden!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _AlertasStockViewState.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ningún material está por debajo del mínimo.',
              style: TextStyle(
                fontSize: 13,
                color: _AlertasStockViewState.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
