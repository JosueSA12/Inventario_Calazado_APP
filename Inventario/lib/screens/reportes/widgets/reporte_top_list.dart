// lib/screens/reportes/widgets/reporte_top_list.dart
import 'package:flutter/material.dart';

class ReporteTopList extends StatelessWidget {
  final List<dynamic> items;
  final String titulo;
  final Color color;
  final String unidad;
  final String subtituloKey;
  final String valorKey;
  final String detalleKey;
  final String detallePrefijo;

  const ReporteTopList({
    super.key,
    required this.items,
    required this.titulo,
    required this.color,
    this.unidad = 'pares',
    this.subtituloKey = 'Color',
    this.valorKey = 'TotalVendido',
    this.detalleKey = 'TotalIngresado',
    this.detallePrefijo = 'S/.',
  });

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildLeading(int index) {
    if (index == 0) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.amber.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('🥇', style: TextStyle(fontSize: 20))),
      );
    } else if (index == 1) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          shape: BoxShape.circle,
        ),
        child: const Center(child: Text('🥈', style: TextStyle(fontSize: 20))),
      );
    } else if (index == 2) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          shape: BoxShape.circle,
        ),
        child: const Center(child: Text('🥉', style: TextStyle(fontSize: 20))),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withOpacity(0.12),
      child: Text(
        "${index + 1}",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getCardColor(int index) {
    if (index == 0) return Colors.amber.shade50;
    if (index == 1) return Colors.grey.shade50;
    if (index == 2) return Colors.orange.shade50;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Top ${items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de items
            ...items.take(5).map((item) {
              final index = items.indexOf(item);
              final modelo = item['Modelo']?.toString() ?? 'Sin modelo';
              final modeloTruncado = _truncateText(modelo, 24);
              final subtitulo = item[subtituloKey]?.toString() ?? '';
              final talla = item['Talla']?.toString() ?? '';
              final valor = item[valorKey] ?? 0;
              final detalle = (item[detalleKey] as num?)?.toDouble() ?? 0.0;

              final isTop3 = index < 3;

              // ✅ Determinar el texto del detalle
              String detalleTexto = '';
              if (detalle > 0) {
                if (detallePrefijo == 'S/.') {
                  detalleTexto =
                      '$detallePrefijo ${detalle.toStringAsFixed(2)}';
                } else if (detallePrefijo == 'Órdenes:') {
                  detalleTexto = '$detallePrefijo ${detalle.toInt()}';
                } else {
                  detalleTexto = '$detallePrefijo ${detalle.toInt()}';
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _getCardColor(index),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isTop3
                        ? color.withOpacity(0.25)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  leading: _buildLeading(index),
                  title: Tooltip(
                    message: modelo,
                    child: Text(
                      modeloTruncado,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  subtitle: Text(
                    "$subtitulo • Talla $talla",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$valor $unidad",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isTop3 ? color : Colors.black87,
                          ),
                        ),
                        if (detalleTexto.isNotEmpty)
                          Text(
                            detalleTexto,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: detallePrefijo == 'S/.'
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if (items.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Y ${items.length - 5} más...',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
