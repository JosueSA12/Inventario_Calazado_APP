import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'formulario_editar.dart';
import 'dialogo_eliminar.dart';
import 'package:inventario/widgets/detalles_view.dart';

class MaterialesView extends StatefulWidget {
  const MaterialesView({super.key});

  @override
  State<MaterialesView> createState() => _MaterialesViewState();
}

class _MaterialesViewState extends State<MaterialesView> {
  String categoriaSeleccionada = 'Todos';
  final String urlMateriales = 'http://10.0.2.2:3000/api/materiales';
  late Future<List<dynamic>> _materialesFuture;

  final List<String> categoriasFiltro = [
    'Todos',
    'Cuero',
    'Suelas',
    'Hilos',
    'Pegamentos / Tintes',
    'Herrajes / Ojales',
  ];

  final Color primaryColor = const Color(0xFF4A3423);
  final Color backgroundColor = const Color(0xFFFDFBF9);
  final Color surfaceColor = Colors.white;
  final Color textDark = const Color(0xFF2C2520);
  final Color textLight = const Color(0xFF7A726C);

  @override
  void initState() {
    super.initState();
    _materialesFuture = obtenerMateriales();
  }

  Future<List<dynamic>> obtenerMateriales() async {
    try {
      final response = await http.get(Uri.parse(urlMateriales));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Fallo en el servidor');
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }

  void _notificarAccion(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // FUNCIÓN PARA MOSTRAR EL DETALLE
  void _mostrarDetalleMaterial(
    BuildContext context,
    Map<String, dynamic> material,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DetalleMaterialGeneralSheet(
        codigo: material['codigo']?.toString() ?? 'S/C',
        insumo: material['insumo']?.toString() ?? 'Sin nombre',
        categoria: material['categoria']?.toString() ?? 'General',
        cantidad: double.tryParse(material['cantidad'].toString()) ?? 0.0,
        medida: material['medida']?.toString() ?? '',
        proveedor: material['proveedor']?.toString() ?? 'Sin Proveedor',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Inventario de Materiales',
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
            onPressed: () => setState(() {
              _materialesFuture = obtenerMateriales();
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILTROS
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categoriasFiltro.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final categoria = categoriasFiltro[index];
                final bool esSeleccionado = categoriaSeleccionada == categoria;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        categoriaSeleccionada = categoria;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: esSeleccionado ? primaryColor : surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: esSeleccionado
                              ? primaryColor
                              : const Color(0xFFEFECE9),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        categoria,
                        style: TextStyle(
                          color: esSeleccionado ? Colors.white : textLight,
                          fontWeight: esSeleccionado
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // LISTA FUTURA DE MATERIALES
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _materialesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF4A3423),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFF991B1B)),
                    ),
                  );
                }

                final todosLosMateriales = snapshot.data ?? [];
                final materialesFiltrados = categoriaSeleccionada == 'Todos'
                    ? todosLosMateriales
                    : todosLosMateriales
                          .where((m) => m['categoria'] == categoriaSeleccionada)
                          .toList();

                if (materialesFiltrados.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay materiales.',
                      style: TextStyle(color: textLight, fontSize: 14),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: materialesFiltrados.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final material = materialesFiltrados[index];

                    Color colorCategoria;
                    IconData iconoMaterial;
                    switch (material['categoria']) {
                      case 'Cuero':
                        colorCategoria = const Color(0xFFD97706);
                        iconoMaterial = Icons.texture_rounded;
                        break;
                      case 'Pegamentos / Tintes':
                        colorCategoria = const Color(0xFF7C3AED);
                        iconoMaterial = Icons.science_rounded;
                        break;
                      case 'Suelas':
                        colorCategoria = const Color(0xFF0D9488);
                        iconoMaterial = Icons.grid_view_rounded;
                        break;
                      case 'Herrajes / Ojales':
                        colorCategoria = const Color(0xFF6B7280);
                        iconoMaterial = Icons.radio_button_checked_rounded;
                        break;
                      default:
                        colorCategoria = const Color(0xFF2563EB);
                        iconoMaterial = Icons.layers_rounded;
                    }

                    final double cantidadNum = double.parse(
                      material['cantidad'].toString(),
                    );
                    final bool bajoStock = cantidadNum < 5.0;

                    return Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A1008).withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // MANEJAR EL CLIC EN LA TARJETA
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              _mostrarDetalleMaterial(context, material),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // A. ICONO DE CATEGORÍA
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorCategoria.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    iconoMaterial,
                                    color: colorCategoria,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        material['insumo'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.business_rounded,
                                            size: 12,
                                            color: textLight.withOpacity(0.6),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              material['proveedor'] ??
                                                  'Sin Proveedor',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: textLight,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (bajoStock) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '⚠️ BAJO STOCK',
                                          style: TextStyle(
                                            color: const Color(0xFFDC2626),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            backgroundColor: const Color(
                                              0xFFFEF2F2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$cantidadNum',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: bajoStock
                                            ? const Color(0xFFDC2626)
                                            : textDark,
                                      ),
                                    ),
                                    Text(
                                      material['medida'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: bajoStock
                                            ? const Color(0xFFEF4444)
                                            : textLight,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),

                                Container(
                                  height: 24,
                                  width: 1,
                                  color: const Color(0xFFEFECE9),
                                ),

                                // BOTÓN ACCIÓN EDITAR
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  onPressed: () async {
                                    final editado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FormularioEditar(
                                          material: material,
                                        ),
                                      ),
                                    );
                                    if (editado == true) {
                                      _notificarAccion(
                                        '🎉 Material actualizado con éxito',
                                        Colors.green.shade700,
                                      );
                                      setState(() {
                                        _materialesFuture = obtenerMateriales();
                                      });
                                    }
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                ),

                                //BOTÓN ACCIÓN ELIMINAR
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFDC2626),
                                    size: 18,
                                  ),
                                  onPressed: () async {
                                    final eliminado = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => DialogoEliminar(
                                        codigo: material['codigo'],
                                        nombre: material['insumo'],
                                      ),
                                    );
                                    if (eliminado == true) {
                                      _notificarAccion(
                                        'Insumo eliminado correctamente',
                                        Colors.brown,
                                      );
                                      setState(() {
                                        _materialesFuture = obtenerMateriales();
                                      });
                                    }
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 2,
                                  ),
                                ),
                              ],
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
    );
  }
}
