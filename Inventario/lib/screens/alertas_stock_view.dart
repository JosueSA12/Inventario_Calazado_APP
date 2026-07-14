import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:inventario/core/theme/app_colors.dart";

import "package:inventario/clases/alerta_material.dart";
import "package:inventario/core/widgets/alerta_card.dart";
import "package:inventario/core/widgets/kpi/detalle_material_sheet.dart";
import "package:inventario/formularios/formulario_abastecer_material.dart";
import "package:inventario/core/services/notification_service.dart";

class AlertasStockView extends StatefulWidget {
  final String? usuarioID;
  const AlertasStockView({super.key, this.usuarioID});

  @override
  State<AlertasStockView> createState() => _AlertasStockViewState();
}

class _AlertasStockViewState extends State<AlertasStockView> {
  final String urlAlertas =
      "http://192.168.100.122:3000/api/materiales/alertas";
  late Future<List<AlertaMaterial>> _alertasFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _categoriaSeleccionada;
  bool _mostrarTodos = true;

  // Lista de categorías para los chips
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
    _alertasFuture = obtenerAlertas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refrescarAlertas() async {
    setState(() {
      _alertasFuture = obtenerAlertas();
    });

    try {
      final alertas = await _alertasFuture;
      if (alertas.isNotEmpty && mounted) {
        final primeraAlerta = alertas.first;
        NotificationService.instance.stockBajo(
          context,
          primeraAlerta.insumo,
          primeraAlerta.cantidad,
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.error(
          context,
          'Error al cargar alertas de stock',
        );
      }
    }
  }

  Future<List<AlertaMaterial>> obtenerAlertas() async {
    try {
      final response = await http
          .get(Uri.parse(urlAlertas))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AlertaMaterial.fromJson(json)).toList();
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("No se pudo conectar: $e");
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _mostrarTodos = true;
      _categoriaSeleccionada = null;
      _searchQuery = "";
      _searchController.clear();
    });
  }

  bool _hayFiltrosActivos() {
    return _categoriaSeleccionada != null;
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

  List<AlertaMaterial> _filtrarYOrdenar(List<AlertaMaterial> alertas) {
    List<AlertaMaterial> resultado = List.from(alertas);

    if (_searchQuery.isNotEmpty) {
      resultado = resultado.where((item) {
        return item.insumo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.proveedor.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.categoria.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (!_mostrarTodos && _categoriaSeleccionada != null) {
      resultado = resultado
          .where((item) => item.categoria == _categoriaSeleccionada)
          .toList();
    }

    // Ordenar por cantidad (menor a mayor - más crítico primero)
    resultado.sort((a, b) => a.cantidad.compareTo(b.cantidad));

    return resultado;
  }

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
        onOrdenarMas: () async {
          Navigator.pop(context);

          final seAbastecio = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormularioAbastecerMaterial(
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
          );
          if (seAbastecio == true) {
            _refrescarAlertas();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<AlertaMaterial>>(
        future: _alertasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.kpiAlertas,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Cargando alertas...",
                    style: TextStyle(color: AppColors.textLight, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.kpiAlertas,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${snapshot.error}".replaceAll("Exception: ", ""),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refrescarAlertas,
                      icon: const Icon(Icons.replay),
                      label: const Text("Reintentar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kpiAlertas,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final alertas = snapshot.data ?? [];
          final alertasFiltradas = _filtrarYOrdenar(alertas);

          return Column(
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
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Buscar alertas",
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
                                _limpiarFiltros();
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
              // FILTRO POR CATEGORÍA CON CHIPS (ESTILO MATERIALES)
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
                            color: AppColors.kpiAlertas.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.filter_list_rounded,
                            color: AppColors.kpiAlertas,
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
                            onPressed: _limpiarFiltros,
                            child: const Text(
                              "Limpiar",
                              style: TextStyle(
                                fontSize: 12,
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
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: _mostrarTodos
                                      ? AppColors.kpiAlertas
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _mostrarTodos
                                        ? AppColors.kpiAlertas
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
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Chips por categoría (con font size 14 y 11)
                          ..._categorias.map((categoria) {
                            final isSelected =
                                _categoriaSeleccionada == categoria;
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
                                        color: isSelected
                                            ? Colors.white
                                            : color,
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
                                          fontSize: 14,
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
              // LISTA DE ALERTAS
              // ==========================================
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.kpiAlertas,
                  onRefresh: _refrescarAlertas,
                  child: alertasFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty || !_mostrarTodos
                                    ? "No se encontraron alertas con estos filtros"
                                    : "No hay alertas de stock bajo",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_searchQuery.isNotEmpty ||
                                  !_mostrarTodos) ...[
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _limpiarFiltros,
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Limpiar filtros",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.kpiAlertas,
                                    side: BorderSide(
                                      color: AppColors.kpiAlertas.withOpacity(
                                        0.5,
                                      ),
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
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 12,
                            bottom: 90,
                          ),
                          itemCount: alertasFiltradas.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return AlertaCard(
                              material: alertasFiltradas[index],
                              onTap: () => _mostrarDetalleMaterial(
                                context,
                                alertasFiltradas[index],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
