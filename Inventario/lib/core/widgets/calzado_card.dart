import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/core/providers/carrito_provider.dart";
import 'package:inventario/core/widgets/custom_animations.dart';

class TarjetaCalzado extends StatefulWidget {
  final List<Map<String, dynamic>> variantes;
  final Function(Map<String, dynamic>) onProduccion;

  const TarjetaCalzado({
    super.key,
    required this.variantes,
    required this.onProduccion,
  });

  @override
  State<TarjetaCalzado> createState() => _TarjetaCalzadoState();
}

class _TarjetaCalzadoState extends State<TarjetaCalzado> {
  late String colorSeleccionado;
  late String tallaSeleccionada;

  late List<String> listaColores;
  late List<String> listaTallas;

  bool _agregando = false;

  @override
  void initState() {
    super.initState();
    _inicializarOpciones();
  }

  void _inicializarOpciones() {
    if (widget.variantes.isEmpty) return;

    listaColores = widget.variantes
        .map((v) => (v["color"] ?? "").toString().trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    colorSeleccionado = listaColores.isNotEmpty ? listaColores.first : "";

    _actualizarTallasParaColor(colorSeleccionado, inicial: true);
  }

  void _actualizarTallasParaColor(String color, {bool inicial = false}) {
    if (color.isEmpty) return;

    var variantesDeColor = widget.variantes.where(
      (v) => (v["color"] ?? "").toString().trim() == color,
    );

    listaTallas = variantesDeColor
        .map((v) => (v["talla"] ?? "").toString().trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();

    listaTallas.sort((a, b) {
      int? numA = int.tryParse(a);
      int? numB = int.tryParse(b);
      if (numA != null && numB != null) return numA.compareTo(numB);
      return a.compareTo(b);
    });

    tallaSeleccionada = listaTallas.isNotEmpty ? listaTallas.first : "";

    if (!inicial) setState(() {});
  }

  String obtenerRutaImagen(String modelo, String color) {
    if (modelo.isEmpty || color.isEmpty) {
      return "imagenes/placeholder.png";
    }

    String quitarAcentos(String texto) {
      return texto
          .toLowerCase()
          .trim()
          .replaceAll("á", "a")
          .replaceAll("é", "e")
          .replaceAll("í", "i")
          .replaceAll("ó", "o")
          .replaceAll("ú", "u")
          .replaceAll("ñ", "n")
          .replaceAll(RegExp(r"[^a-z0-9\s]"), "")
          .replaceAll(" ", "_");
    }

    String mod = quitarAcentos(modelo);
    String col = quitarAcentos(color);

    return "assets/imagenes/${mod}_$col.png";
  }

  Color _mapearColorHex(String colorNombre) {
    switch (colorNombre.toLowerCase()) {
      case "negro":
        return Colors.black;
      case "marrón":
      case "marron":
        return const Color(0xFF7A431D);
      case "blanco":
        return Colors.white;
      case "gris":
        return Colors.grey;
      case "azul":
        return Colors.blue.shade900;
      default:
        return Colors.grey.shade400;
    }
  }

  // ==========================================
  // SHOW SUCCESS DIALOG (CON CONFETI)
  // ==========================================
  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) Navigator.pop(context);
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -20,
                    left: -20,
                    right: -20,
                    bottom: -20,
                    child: const ConfettiAnimation(
                      particleCount: 40,
                      size: 200,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SuccessAnimation(size: 80),
                      const SizedBox(height: 16),
                      const Text(
                        "¡Producto agregado!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Se añadió al carrito correctamente",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shopping_cart_rounded,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Carrito actualizado",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // SHOW LOADING DIALOG
  // ==========================================
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingAnimation(size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "Agregando al carrito...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // SHOW ERROR DIALOG
  // ==========================================
  void _showErrorAnimation(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ErrorAnimation(size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    "¡Error!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mensaje,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // AGREGAR AL CARRITO
  // ==========================================
  void _agregarAlCarrito(BuildContext context) async {
    if (_agregando) return;

    final carritoProvider = Provider.of<CarritoProvider>(
      context,
      listen: false,
    );

    final varianteActual = widget.variantes.firstWhere(
      (v) =>
          (v["color"] ?? "").toString().trim() == colorSeleccionado &&
          (v["talla"] ?? "").toString().trim() == tallaSeleccionada,
      orElse: () => widget.variantes.first,
    );

    final String modelo =
        varianteActual["modelo"]?.toString() ?? "Modelo Desconocido";
    final String codigo = varianteActual["codigo"]?.toString() ?? "";
    final double precio =
        double.tryParse(varianteActual["precio"]?.toString() ?? "0") ?? 0.0;
    final int stock =
        int.tryParse(varianteActual["stock"]?.toString() ?? "0") ?? 0;

    // Mostrar diálogo de cantidad
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        int cantidad = 1;
        return StatefulBuilder(
          builder: (stateContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.green,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Agregar al Carrito",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modelo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Color: $colorSeleccionado • Talla: $tallaSeleccionada",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Text(
                    "Precio: S/. ${precio.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Stock disponible: $stock pares",
                    style: TextStyle(
                      fontSize: 12,
                      color: stock < 5
                          ? AppColors.kpiAlertas
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        "Cantidad:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          if (cantidad > 1) {
                            setStateDialog(() => cantidad--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        "$cantidad",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (cantidad < stock) {
                            setStateDialog(() => cantidad++);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(stateContext),
                  child: const Text("Cancelar"),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Cerrar diálogo de cantidad
                      Navigator.pop(stateContext);

                      // Mostrar loading
                      _showLoadingDialog(context);

                      setState(() => _agregando = true);

                      final success = await carritoProvider.agregarItem(
                        codigo: codigo,
                        descripcion:
                            "$modelo ($colorSeleccionado - Talla $tallaSeleccionada)",
                        cantidad: cantidad,
                        precio: precio,
                        stock: stock,
                      );

                      // Cerrar loading
                      Navigator.pop(context);

                      setState(() => _agregando = false);

                      if (!mounted) return;

                      if (success) {
                        _showSuccessAnimation(context);
                      } else {
                        _showErrorAnimation(
                          context,
                          "No se pudo agregar al carrito",
                        );
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text(
                      "Añadir al Carrito",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variantes.isEmpty) {
      return const Card(child: Center(child: Text("Sin datos")));
    }

    final varianteActual = widget.variantes.firstWhere(
      (v) =>
          (v["color"] ?? "").toString().trim() == colorSeleccionado &&
          (v["talla"] ?? "").toString().trim() == tallaSeleccionada,
      orElse: () => widget.variantes.first,
    );

    final String modelo =
        varianteActual["modelo"]?.toString() ?? "Modelo Desconocido";
    final String tipo = varianteActual["tipo"]?.toString() ?? "Calzado";
    final double precio =
        double.tryParse(varianteActual["precio"]?.toString() ?? "0") ?? 0.0;
    final int stock =
        int.tryParse(varianteActual["stock"]?.toString() ?? "0") ?? 0;
    final bool bajoStock = varianteActual["bajoStock"] == 1 || stock < 5;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 160,
                      height: 160,
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
                                "Imagen no disponible",
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
                          "¡Poco Stock!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tipo.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // DETALLES
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modelo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Color:",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: seleccionado
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: _mapearColorHex(colorItem),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 6),
                Text(
                  "Talla:",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: seleccionada
                                ? AppColors.primary
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: seleccionada
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            tallaItem,
                            style: TextStyle(
                              fontSize: 11,
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

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "S/. ${precio.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      "Stk: $stock",
                      style: TextStyle(
                        fontSize: 12,
                        color: bajoStock ? Colors.red : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // BOTONES
                Column(
                  children: [
                    // Botón "Añadir al Carrito"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: stock > 0
                            ? () => _agregarAlCarrito(context)
                            : null,
                        icon: _agregando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16,
                              ),
                        label: Text(
                          stock > 0 ? 'Añadir al Carrito' : 'Sin Stock',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _agregando
                              ? Colors.blue.shade400
                              : (stock > 0
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade400),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Botón Producir
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final calzadoSeleccionado = {
                            'codigo': varianteActual["codigo"],
                            'modelo': modelo,
                            'tipo': tipo,
                            'color': colorSeleccionado,
                            'talla': tallaSeleccionada,
                            'precio': precio,
                            'stock': stock,
                          };
                          widget.onProduccion(calzadoSeleccionado);
                        },
                        icon: const Icon(Icons.factory_rounded, size: 16),
                        label: const Text(
                          'Producir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
