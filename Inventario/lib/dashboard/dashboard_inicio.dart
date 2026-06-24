import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Paleta de colores profesional
  final Color primaryColor = const Color(
    0xFF4A3423,
  ); // Marrón artesanal profundo
  final Color backgroundColor = const Color(0xFFFDFBF9); // Blanco hueso limpio
  final Color surfaceColor = Colors.white;
  final Color textDark = const Color(
    0xFF2C2520,
  ); // Gris casi negro para legibilidad
  final Color textLight = const Color(0xFF7A726C); // Gris secundario suave

  @override
  void initState() {
    super.initState();
    _resumenFuture = obtenerResumen();
    _actividadFuture = obtenerActividad();
  }

  Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      final response = await http.get(Uri.parse(urlResumen));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Fallo en el servidor');
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }

  Future<List<dynamic>> obtenerActividad() async {
    try {
      final response = await http.get(Uri.parse(urlActividad));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Fallo en el servidor');
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Panel de Control',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryColor),
            onPressed: () {
              setState(() {
                _resumenFuture = obtenerResumen();
                _actividadFuture = obtenerActividad();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Resumen del Taller',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textLight,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // ==========================================
              // SECCIÓN TARJETAS (KPIs)
              // ==========================================
              FutureBuilder<Map<String, dynamic>>(
                future: _resumenFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _shimmerLoadingKpis();
                  } else if (snapshot.hasError) {
                    return _cardError('Error KPIs: ${snapshot.error}');
                  }

                  final kpis = snapshot.data;
                  final totalModelos = kpis?['TotalModelos']?.toString() ?? '0';
                  final totalMateriales =
                      kpis?['TotalMateriales']?.toString() ?? '0';
                  final alertasCriticas =
                      kpis?['AlertasCriticas']?.toString() ?? '0';

                  return Row(
                    children: [
                      Expanded(
                        child: _tarjetaKpi(
                          'Modelos',
                          totalModelos,
                          const Color(0xFF2F80ED),
                          Icons.layers_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _tarjetaKpi(
                          'Insumos',
                          totalMateriales,
                          const Color(0xFFF2994A),
                          Icons.handyman_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _tarjetaKpi(
                          'Alertas',
                          alertasCriticas,
                          const Color(0xFFEB5757),
                          Icons.error_outline_rounded,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Últimos Movimientos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Recientes',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ==========================================
              // SECCIÓN HISTORIAL
              // ==========================================
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _actividadFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFF4A3423),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return _cardError('Error Historial: ${snapshot.error}');
                    }

                    final movimientos = snapshot.data!;
                    if (movimientos.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay movimientos recientes.',
                          style: TextStyle(color: textLight, fontSize: 14),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: movimientos.length,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = movimientos[index];
                        final esMaterial = item['Tipo'] == 'Material';
                        final esSalida = item['Movimiento']
                            .toString()
                            .toLowerCase()
                            .contains('salida');

                        return Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1A1008,
                                ).withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: esMaterial
                                    ? const Color(0xFFFFF7ED)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                esMaterial
                                    ? Icons.construction_rounded
                                    : Icons.style_rounded,
                                color: esMaterial
                                    ? const Color(0xFFEA580C)
                                    : const Color(0xFF2563EB),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              item['Descripcion'] ?? 'Sin Descripción',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textDark,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                '${item['Movimiento']} • ${item['Encargado']}',
                                style: TextStyle(
                                  color: textLight,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: esSalida
                                    ? const Color(0xFFFEF2F2)
                                    : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['Cantidad']?.toString() ?? '0',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: esSalida
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _tarjetaKpi(String titulo, String valor, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECE9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1008).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: textLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Icon(icono, color: color.withOpacity(0.7), size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLoadingKpis() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            height: 85,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEFECE9)),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardError(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        mensaje,
        style: const TextStyle(
          color: Color(0xFF991B1B),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
