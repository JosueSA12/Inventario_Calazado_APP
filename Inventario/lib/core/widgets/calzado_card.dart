import 'package:flutter/material.dart';

class TarjetaCalzado extends StatefulWidget {
  final List<Map<String, dynamic>> variantes;

  const TarjetaCalzado({super.key, required this.variantes});

  @override
  State<TarjetaCalzado> createState() => _TarjetaCalzadoState();
}

class _TarjetaCalzadoState extends State<TarjetaCalzado> {
  late String colorSeleccionado;
  late String tallaSeleccionada;

  late List<String> listaColores;
  late List<String> listaTallas;

  @override
  void initState() {
    super.initState();
    _inicializarOpciones();
  }

  void _inicializarOpciones() {
    if (widget.variantes.isEmpty) return;

    listaColores = widget.variantes
        .map((v) => (v['color'] ?? '').toString().trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    colorSeleccionado = listaColores.isNotEmpty ? listaColores.first : '';

    _actualizarTallasParaColor(colorSeleccionado, inicial: true);
  }

  void _actualizarTallasParaColor(String color, {bool inicial = false}) {
    if (color.isEmpty) return;

    var variantesDeColor = widget.variantes.where(
      (v) => (v['color'] ?? '').toString().trim() == color,
    );

    listaTallas = variantesDeColor
        .map((v) => (v['talla'] ?? '').toString().trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();

    listaTallas.sort((a, b) {
      int? numA = int.tryParse(a);
      int? numB = int.tryParse(b);
      if (numA != null && numB != null) return numA.compareTo(numB);
      return a.compareTo(b);
    });

    tallaSeleccionada = listaTallas.isNotEmpty ? listaTallas.first : '';

    if (!inicial) setState(() {});
  }

  String obtenerRutaImagen(String modelo, String color) {
    if (modelo.isEmpty || color.isEmpty) {
      return 'imagenes/placeholder.png';
    }

    String quitarAcentos(String texto) {
      return texto
          .toLowerCase()
          .trim()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ñ', 'n')
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
          .replaceAll(' ', '_');
    }

    String mod = quitarAcentos(modelo);
    String col = quitarAcentos(color);

    return 'imagenes/${mod}_$col.png';
  }

  Color _mapearColorHex(String colorNombre) {
    switch (colorNombre.toLowerCase()) {
      case 'negro':
        return Colors.black;
      case 'marrón':
      case 'marron':
        return const Color(0xFF7A431D);
      case 'blanco':
        return Colors.white;
      case 'gris':
        return Colors.grey;
      case 'azul':
        return Colors.blue.shade900;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variantes.isEmpty) {
      return const Card(child: Center(child: Text('Sin datos')));
    }

    final varianteActual = widget.variantes.firstWhere(
      (v) =>
          (v['color'] ?? '').toString().trim() == colorSeleccionado &&
          (v['talla'] ?? '').toString().trim() == tallaSeleccionada,
      orElse: () => widget.variantes.first,
    );

    final String modelo =
        varianteActual['modelo']?.toString() ?? 'Modelo Desconocido';
    final String tipo = varianteActual['tipo']?.toString() ?? 'Calzado';
    final double precio =
        double.tryParse(varianteActual['precio']?.toString() ?? '0') ?? 0.0;
    final int stock =
        int.tryParse(varianteActual['stock']?.toString() ?? '0') ?? 0;
    final bool bajoStock = varianteActual['bajoStock'] == 1 || stock < 5;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.asset(
                        obtenerRutaImagen(modelo, colorSeleccionado),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Imagen no disponible',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  if (bajoStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '¡Poco Stock!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          //  DETALLES
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  modelo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Color:',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: listaColores.map((colorItem) {
                    final bool seleccionado = colorSeleccionado == colorItem;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          colorSeleccionado = colorItem;
                          _actualizarTallasParaColor(colorItem);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: seleccionado
                                ? const Color(0xFF4A3423)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: _mapearColorHex(colorItem),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),
                const Text(
                  'Talla:',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: listaTallas.map((tallaItem) {
                      final bool seleccionada = tallaSeleccionada == tallaItem;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => tallaSeleccionada = tallaItem),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: seleccionada
                                ? const Color(0xFF4A3423)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: seleccionada
                                  ? const Color(0xFF4A3423)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            tallaItem,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: seleccionada
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'S/. ${precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3423),
                      ),
                    ),
                    Text(
                      'Stk: $stock',
                      style: TextStyle(
                        fontSize: 13,
                        color: bajoStock ? Colors.red : Colors.green,
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
