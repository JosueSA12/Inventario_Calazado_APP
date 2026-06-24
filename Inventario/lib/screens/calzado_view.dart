import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalzadosView extends StatefulWidget {
  const CalzadosView({super.key});

  @override
  State<CalzadosView> createState() => _CalzadosViewState();
}

class _CalzadosViewState extends State<CalzadosView> {
  final String urlCalzados = 'http://10.0.2.2:3000/api/calzados';
  late Future<List<dynamic>> _calzadosFuture;

  final Color primaryColor = const Color(0xFF4A3423);
  final Color backgroundColor = const Color(0xFFF6F5F3);
  final Color textDark = const Color(0xFF1C1917);

  @override
  void initState() {
    super.initState();
    _calzadosFuture = obtenerCalzados();
  }

  Future<List<dynamic>> obtenerCalzados() async {
    try {
      final response = await http.get(Uri.parse(urlCalzados));
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Error en el servidor');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Calzados en Inventario',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _calzadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A3423)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final calzados = snapshot.data ?? [];
          if (calzados.isEmpty) {
            return const Center(child: Text('No hay calzados disponibles.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: calzados.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio:
                  0.62, // Un poco más alto para dar espacio a los círculos de color
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              // Enviamos el registro individual a un Widget independiente para que cada carta controle su propio color seleccionado
              return TarjetaCalzadoConColor(item: calzados[index]);
            },
          );
        },
      ),
    );
  }
}

// =========================================================================
// COMPONENTE: TARJETA DE CALZADO CON SELECTOR DINÁMICO DE COLOR
// =========================================================================
class TarjetaCalzadoConColor extends StatefulWidget {
  final Map<String, dynamic> item;
  const TarjetaCalzadoConColor({super.key, required this.item});

  @override
  State<TarjetaCalzadoConColor> createState() => _TarjetaCalzadoConColorState();
}

class _TarjetaCalzadoConColorState extends State<TarjetaCalzadoConColor> {
  late String _colorActual;

  final Map<String, String> _galeriaDeInternet = {
    // BOTAS
    'bota_negro':
        'https://mauiandsons.com.pe/zapatillas-urbanas-k-grind-hombre-azul1000321028p.html?srsltid=AfmBOor2Z2-HggNgJ5YDavKKMrSx_QTzgwLeKymZq52gc1ZL8dAWbVia',
    'bota_marron':
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=500&q=80',
    'bota_miel':
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500&q=80',

    // ZAPATILLAS / DEPORTIVOS
    'deportivo_negro':
        'https://mauiandsons.com.pe/zapatillas-urbanas-k-grind-hombre-azul1000321028p.html?srsltid=AfmBOor2Z2-HggNgJ5YDavKKMrSx_QTzgwLeKymZq52gc1ZL8dAWbVia',
    'deportivo_blanco':
        'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=500&q=80',
    'deportivo_azul':
        'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=500&q=80',

    // FORMAL / VESTIR
    'formal_negro':
        'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=500&q=80',
    'formal_marron':
        'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=500&q=80',
  };

  @override
  void initState() {
    super.initState();
    _colorActual = widget.item['color'] ?? 'Negro';
  }

  String _obtenerImagenDinamica(String tipo, String color) {
    final tipoKey = tipo.toLowerCase().trim();
    final colorKey = color.toLowerCase().trim();

    String llaveBusqueda = '${tipoKey}_$colorKey';
    if (_galeriaDeInternet.containsKey(llaveBusqueda)) {
      return _galeriaDeInternet[llaveBusqueda]!;
    }

    // Si no encuentra el color exacto, busca por tipo genérico
    if (tipoKey.contains('bota')) return _galeriaDeInternet['bota_marron']!;
    if (tipoKey.contains('depor') || tipoKey.contains('zapa'))
      return _galeriaDeInternet['deportivo_negro']!;

    return 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=500&q=80';
  }

  Color _mapearColorHex(String nombreColor) {
    final c = nombreColor.toLowerCase().trim();
    if (c == 'negro') return Colors.black;
    if (c == 'marron' || c == 'marrón') return const Color(0xFF78350F);
    if (c == 'miel' || c == 'beige') return const Color(0xFFD97706);
    if (c == 'blanco') return Colors.white;
    if (c == 'azul') return Colors.blue.shade900;
    return Colors.grey; // Color por defecto si viene un color extraño
  }

  @override
  Widget build(BuildContext context) {
    final String modelo = widget.item['modelo'] ?? 'Modelo';
    final String tipo = widget.item['tipo'] ?? 'General';
    final String talla = widget.item['talla']?.toString() ?? '--';
    final int stock =
        int.tryParse(widget.item['stock']?.toString() ?? '0') ?? 0;
    final double precio =
        double.tryParse(widget.item['precio']?.toString() ?? '0.0') ?? 0.0;
    final bool bajoStock =
        widget.item['bajoStock'] == true || widget.item['bajoStock'] == 1;

    final List<String> coloresDisponibles = ['Negro', 'Marron', 'Miel'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGEN CAMBIANTE (Usa _colorActual)
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        _obtenerImagenDinamica(tipo, _colorActual),
                      ), // <--- DINÁMICO
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (bajoStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CRÍTICO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // DETALLES Y SELECTOR DE COLOR
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF4A3423),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  modelo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                // OPCIÓN INTERACTIVA
                Row(
                  children: coloresDisponibles.map((colorItem) {
                    final bool esElSeleccionado =
                        _colorActual.toLowerCase() == colorItem.toLowerCase();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _colorActual = colorItem;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: esElSeleccionado
                                ? const Color(0xFF4A3423)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: _mapearColorHex(colorItem),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),
                Text(
                  'Talla: $talla',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 6),

                // Fila de precio y stock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'S/. ${precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Stk: $stock',
                      style: TextStyle(
                        fontSize: 11,
                        color: bajoStock ? Colors.red : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
