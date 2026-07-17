import 'package:flutter/material.dart';
import 'package:inventario/core/utils/formato_fechas.dart';

class ReporteChart extends StatefulWidget {
  final List items;
  final String titulo;
  final String valorKey;
  final String unidad;
  final String? tipoFiltro; // DIA, SEMANA, MES, ANIO, RANGO

  const ReporteChart({
    super.key,
    required this.items,
    required this.titulo,
    required this.valorKey,
    this.unidad = 'pares',
    this.tipoFiltro,
  });

  @override
  State<ReporteChart> createState() => _ReporteChartState();
}

class _ReporteChartState extends State<ReporteChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  static const List<Color> _paletaColores = [
    Color(0xFF4FC3F7),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
    Color(0xFF26C6DA),
    Color(0xFFFFEE58),
    Color(0xFF8D6E63),
    Color(0xFF42A5F5),
    Color(0xFF26A69A),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant ReporteChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _animationController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getColor(int index) {
    return _paletaColores[index % _paletaColores.length];
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FILTRAR SOLO ITEMS CON VALOR > 0
    final itemsFiltrados = widget.items
        .where((item) => (item[widget.valorKey] ?? 0) > 0)
        .toList();

    if (itemsFiltrados.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No hay datos para mostrar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 40,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No hay datos para mostrar',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    }

    // ✅ USAR itemsFiltrados para los cálculos
    final maxValor = itemsFiltrados.take(10).fold<double>(0, (max, item) {
      final valor = (item[widget.valorKey] ?? 0).toDouble();
      return valor > max ? valor : max;
    });

    final tituloDinamico = FormatoFechas.tituloGrafico(
      widget.titulo,
      widget.tipoFiltro,
    );

    final Color colorPrincipal = _paletaColores.first;

    final int total = itemsFiltrados.take(10).fold<int>(0, (sum, item) {
      return sum + ((item[widget.valorKey] ?? 0) as int);
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: colorPrincipal, size: 20),
                const SizedBox(width: 8),
                Text(
                  tituloDinamico,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorPrincipal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${itemsFiltrados.length} días con datos',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorPrincipal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: itemsFiltrados
                        .take(10)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          final valor = (item[widget.valorKey] ?? 0).toDouble();
                          final porcentaje = maxValor > 0
                              ? valor / maxValor
                              : 0;
                          final alturaFinal = porcentaje * 140;
                          final alturaActual = alturaFinal * _animation.value;
                          final Color color = _getColor(index);

                          DateTime fecha;
                          try {
                            fecha = DateTime.parse(item['Fecha']);
                          } catch (e) {
                            fecha = DateTime.now();
                          }

                          final etiqueta = FormatoFechas.formatearPorFiltro(
                            fecha,
                            widget.tipoFiltro,
                          );

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (valor > 0)
                                  Text(
                                    valor.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Container(
                                  height: alturaActual > 2 ? alturaActual : 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [color.withOpacity(0.5), color],
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                        alturaActual > 4 ? 4 : 0,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  etiqueta,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Container(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: $total ${widget.unidad}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Días: ${itemsFiltrados.length}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  'Máximo: ${maxValor.toInt()} ${widget.unidad}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorPrincipal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
