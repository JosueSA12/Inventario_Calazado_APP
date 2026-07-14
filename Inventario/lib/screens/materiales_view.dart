import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/clases/mostrar_material.dart";
import "package:inventario/core/widgets/material_card.dart";
import "package:inventario/core/widgets/kpi/detalle_material_sheet.dart";
import "package:inventario/formularios/formulario_editar.dart";
import "package:inventario/formularios/dialogo_eliminar.dart";
import "package:inventario/formularios/formulario_nuevo_material.dart";
import "package:inventario/formularios/formulario_abastecer_material.dart";
import "package:inventario/core/services/notification_service.dart";

class MaterialesView extends StatefulWidget {
  final String? usuarioID;
  const MaterialesView({super.key, this.usuarioID});

  @override
  State<MaterialesView> createState() => _MaterialesViewState();
}

class _MaterialesViewState extends State<MaterialesView> {
  final String urlMateriales = "http://192.168.100.122:3000/api/materiales";
  late Future<List<MaterialModel>> _materialesFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  String? _categoriaSeleccionada;
  bool _mostrarTodos = true;

  final List<String> _categorias = [
    "Cuero",
    "Suelas",
    "Hilos",
    "Pegamentos / Tintes",
    "Herrajes / Ojales",
  ];

  @override
  void initState() {
    super.initState();
    _materialesFuture = obtenerMateriales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<MaterialModel>> obtenerMateriales() async {
    try {
      final response = await http.get(Uri.parse(urlMateriales));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MaterialModel.fromJson(json)).toList();
      }
      throw Exception("Error del servidor");
    } catch (e) {
      throw Exception("No se pudo conectar: $e");
    }
  }

  Future<void> _refrescarLista() async {
    setState(() {
      _materialesFuture = obtenerMateriales();
    });
  }

  void _navegarARegistrarMaterial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioNuevoMaterial(usuarioID: widget.usuarioID),
      ),
    ).then((result) {
      if (result == true) {
        NotificationService.instance.exito(
          context,
          'Material registrado correctamente',
        );
        _refrescarLista();
      }
    });
  }

  List<MaterialModel> _filtrarMateriales(List<MaterialModel> materiales) {
    List<MaterialModel> resultado = List.from(materiales);

    if (_searchQuery.isNotEmpty) {
      resultado = resultado
          .where(
            (m) =>
                m.insumo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                m.proveedor.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                m.codigo.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (!_mostrarTodos && _categoriaSeleccionada != null) {
      resultado = resultado
          .where((m) => m.categoria == _categoriaSeleccionada)
          .toList();
    }

    return resultado;
  }

  bool _hayFiltrosActivos() {
    return _categoriaSeleccionada != null;
  }

  void _limpiarFiltros() {
    setState(() {
      _mostrarTodos = true;
      _categoriaSeleccionada = null;
    });
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case "Cuero":
        return Icons.style_rounded;
      case "Suelas":
        return Icons.shop_two_rounded;
      case "Hilos":
        return Icons.timeline_rounded;
      case "Pegamentos / Tintes":
        return Icons.color_lens_rounded;
      case "Herrajes / Ojales":
        return Icons.build_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case "Cuero":
        return Colors.brown.shade700;
      case "Suelas":
        return Colors.blue.shade700;
      case "Hilos":
        return Colors.purple.shade700;
      case "Pegamentos / Tintes":
        return Colors.orange.shade700;
      case "Herrajes / Ojales":
        return Colors.grey.shade700;
      default:
        return AppColors.primary;
    }
  }

  void _mostrarDetalle(BuildContext context, MaterialModel material) {
    if (material.esBajoStock) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => DetalleBajoStockSheet(
          codigo: material.codigo,
          insumo: material.insumo,
          categoria: material.categoria,
          cantidad: material.cantidad,
          medida: material.medida,
          proveedor: material.proveedor,
          onOrdenarMas: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormularioAbastecerMaterial(
                  materialInicial: {
                    "codigo": material.codigo,
                    "insumo": material.insumo,
                    "categoria": material.categoria,
                    "cantidad": material.cantidad,
                    "medida": material.medida,
                    "proveedor": material.proveedor,
                  },
                  usuarioID: widget.usuarioID,
                ),
              ),
            ).then((_) => _refrescarLista());
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => DetalleMaterialGeneralSheet(
          codigo: material.codigo,
          insumo: material.insumo,
          categoria: material.categoria,
          cantidad: material.cantidad,
          medida: material.medida,
          proveedor: material.proveedor,
        ),
      );
    }
  }

  void _aplicarFiltro() {
    setState(() {
      _materialesFuture = Future.delayed(
        const Duration(milliseconds: 300),
        () => obtenerMateriales(),
      ).then((value) => value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarARegistrarMaterial,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Registrar"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          // ==========================================
          // BARRA DE BÚSQUEDA
          // ==========================================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _aplicarFiltro();
                },
                decoration: InputDecoration(
                  hintText: "Buscar material...",
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                            _aplicarFiltro();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ==========================================
          // FILTRO POR CATEGORÍA CON CHIPS
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Filtrar por categoría:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (!_mostrarTodos || _hayFiltrosActivos())
                      TextButton(
                        onPressed: () {
                          _limpiarFiltros();
                          _aplicarFiltro();
                        },
                        child: const Text(
                          "Limpiar",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.kpiAlertas,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Chip "Todos"
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _mostrarTodos = true;
                              _categoriaSeleccionada = null;
                            });
                            _aplicarFiltro();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: _mostrarTodos
                                  ? AppColors.primary
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _mostrarTodos
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "Todos",
                              style: TextStyle(
                                fontWeight: _mostrarTodos
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _mostrarTodos
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Chips por categoría
                      ..._categorias.map((categoria) {
                        final isSelected = _categoriaSeleccionada == categoria;
                        final color = _getCategoryColor(categoria);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _mostrarTodos = true;
                                  _categoriaSeleccionada = null;
                                } else {
                                  _mostrarTodos = false;
                                  _categoriaSeleccionada = categoria;
                                }
                              });
                              _aplicarFiltro();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(categoria),
                                    size: 14,
                                    color: isSelected ? Colors.white : color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    categoria,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ==========================================
          // LISTA DE MATERIALES
          // ==========================================
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refrescarLista, // ✅ Pull-to-refresh
              child: FutureBuilder<List<MaterialModel>>(
                future: _materialesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Cargando materiales...",
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    NotificationService.instance.error(
                      context,
                      'Error al cargar materiales',
                    );
                  }

                  final materiales = _filtrarMateriales(snapshot.data ?? []);

                  if (materiales.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || !_mostrarTodos
                                ? "No se encontraron materiales con estos filtros"
                                : "No hay materiales registrados",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty || !_mostrarTodos) ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                _limpiarFiltros();
                                _aplicarFiltro();
                              },
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              label: const Text(
                                "Limpiar filtros",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.kpiAlertas,
                                side: BorderSide(
                                  color: AppColors.kpiAlertas.withOpacity(0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: ListView.separated(
                      key: ValueKey(materiales.length),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                        bottom: 90,
                      ),
                      itemCount: materiales.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final material = materiales[index];
                        return MaterialCard(
                          material: material,
                          onTap: () => _mostrarDetalle(context, material),
                          onEdit: () async {
                            final materialMap = {
                              "codigo": material.codigo,
                              "insumo": material.insumo,
                              "categoria": material.categoria,
                              "cantidad": material.cantidad,
                              "medida": material.medida,
                              "proveedor": material.proveedor,
                            };

                            final editado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FormularioEditar(material: materialMap),
                              ),
                            );

                            if (editado == true) {
                              NotificationService.instance.exito(
                                context,
                                'Material actualizado correctamente',
                              );
                              _refrescarLista();
                            }
                          },
                          onDelete: () async {
                            final eliminado = await showDialog<bool>(
                              context: context,
                              builder: (_) => DialogoEliminar(
                                codigo: material.codigo,
                                nombre: material.insumo,
                                usuarioID: widget.usuarioID,
                              ),
                            );
                            if (eliminado == true) {
                              NotificationService.instance.exito(
                                context,
                                'Material eliminado correctamente',
                              );
                              _refrescarLista();
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
