import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/core/widgets/calzado_card.dart";
import "package:inventario/core/services/notification_service.dart";
import 'package:inventario/screens/produccion/produccion_screen.dart';

class CalzadosView extends StatefulWidget {
  final String? usuarioID;
  const CalzadosView({super.key, this.usuarioID});

  @override
  State<CalzadosView> createState() => _CalzadosViewState();
}

class _CalzadosViewState extends State<CalzadosView> {
  final String urlCalzados = "http://192.168.100.122:3000/api/calzados";
  late Future<List<dynamic>> _calzadosFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";
  String? _tipoSeleccionado;
  bool _mostrarTodos = true;

  final List<String> _tipos = [
    'Bota',
    'Formal',
    'Urbano',
    'Deportivo',
    'Tacos',
    'Sandalia',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    _calzadosFuture = obtenerCalzados();
  }

  Future<List<dynamic>> obtenerCalzados() async {
    try {
      final response = await http.get(Uri.parse(urlCalzados));
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception("Error en el servidor");
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  Future<void> _refrescarLista() async {
    setState(() {
      _cargarDatos();
    });
  }

  void _navegarARegistrarProduccion(Map<String, dynamic>? calzado) {
    final calzadoCompleto = calzado != null
        ? {
            'codigo': calzado['codigo'] ?? '',
            'modelo': calzado['modelo'] ?? '',
            'tipo': calzado['tipo'] ?? '',
            'color': calzado['color'] ?? '',
            'talla': calzado['talla']?.toString() ?? '',
            'precio': calzado['precio'] ?? 0.0,
            'stock': calzado['stock'] ?? 0,
          }
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProduccionScreen(
          calzadoInicial: calzadoCompleto,
          usuarioID: widget.usuarioID,
        ),
      ),
    ).then((result) {
      if (result == true) {
        NotificationService.instance.exito(
          context,
          'Producción registrada correctamente',
        );
        _refrescarLista();
      }
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _mostrarTodos = true;
      _tipoSeleccionado = null;
      _searchTerm = "";
      _searchController.clear();
    });
  }

  bool _hayFiltrosActivos() {
    return _tipoSeleccionado != null;
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'Bota':
        return Icons.work_rounded;
      case 'Formal':
        return Icons.room_service_rounded;
      case 'Urbano':
        return Icons.directions_walk_rounded;
      case 'Deportivo':
        return Icons.directions_run_rounded;
      case 'Tacos':
        return Icons.style_rounded;
      case 'Sandalias':
        return Icons.beach_access_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'Bota':
        return Colors.brown.shade700;
      case 'Formal':
        return Colors.blue.shade700;
      case 'Urbano':
        return Colors.green.shade700;
      case 'Deportivo':
        return Colors.red.shade700;
      case 'Tacos':
        return Colors.pink.shade400;
      case 'Sandalias':
        return Colors.orange.shade700;
      default:
        return AppColors.primary;
    }
  }

  List<dynamic> _aplicarFiltros(List<dynamic> lista) {
    List<dynamic> resultado = List.from(lista);

    if (_searchTerm.isNotEmpty) {
      final busqueda = _searchTerm.toLowerCase();
      resultado = resultado.where((item) {
        final modelo = (item["modelo"] ?? "").toString().toLowerCase();
        final tipo = (item["tipo"] ?? "").toString().toLowerCase();
        final color = (item["color"] ?? "").toString().toLowerCase();
        return modelo.contains(busqueda) ||
            tipo.contains(busqueda) ||
            color.contains(busqueda);
      }).toList();
    }

    if (!_mostrarTodos && _tipoSeleccionado != null) {
      resultado = resultado
          .where(
            (item) =>
                (item["tipo"] ?? "").toString().toLowerCase() ==
                _tipoSeleccionado!.toLowerCase(),
          )
          .toList();
    }

    return resultado;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // BARRA DE BÚSQUEDA
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
                  onChanged: (value) => setState(() => _searchTerm = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar calzado',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade500,
                    ),
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchTerm = "");
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

            // FILTROS TIPO CHIPS
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
                          color: Colors.purple.shade700.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: Colors.purple.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Filtrar por tipo:",
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
                            'Limpiar',
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _mostrarTodos = true;
                                _tipoSeleccionado = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _mostrarTodos
                                    ? Colors.purple.shade700
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _mostrarTodos
                                      ? Colors.purple.shade700
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Todos',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ..._tipos.map((tipo) {
                          final isSelected = _tipoSeleccionado == tipo;
                          final color = _getTipoColor(tipo);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _mostrarTodos = true;
                                    _tipoSeleccionado = null;
                                  } else {
                                    _mostrarTodos = false;
                                    _tipoSeleccionado = tipo;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
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
                                      _getTipoIcon(tipo),
                                      size: 14,
                                      color: isSelected ? Colors.white : color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      tipo,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
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

            // LISTA DE CALZADOS
            Expanded(
              child: RefreshIndicator(
                color: Colors.purple.shade700,
                onRefresh: _refrescarLista,
                child: FutureBuilder<List<dynamic>>(
                  future: _calzadosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.purple,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Cargando calzados...',
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
                        'Error al cargar calzados',
                      );
                    }

                    final listaFiltrada = _aplicarFiltros(snapshot.data!);

                    if (listaFiltrada.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchTerm.isNotEmpty ||
                                      !_mostrarTodos ||
                                      _hayFiltrosActivos()
                                  ? 'No se encontraron calzados con estos filtros'
                                  : 'No hay calzados registrados',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            if (_searchTerm.isNotEmpty ||
                                !_mostrarTodos ||
                                _hayFiltrosActivos()) ...[
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _limpiarFiltros,
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                label: const Text(
                                  'Limpiar filtros',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                      );
                    }

                    Map<String, List<Map<String, dynamic>>> agrupados = {};
                    for (var item in listaFiltrada) {
                      final map = Map<String, dynamic>.from(item);
                      final modelo = map["modelo"]?.toString() ?? "Sin modelo";
                      agrupados.putIfAbsent(modelo, () => []).add(map);
                    }

                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.50,
                            ),
                        itemCount: agrupados.length,
                        itemBuilder: (context, index) {
                          final modelo = agrupados.keys.elementAt(index);
                          return TarjetaCalzado(
                            variantes: agrupados[modelo]!,
                            onProduccion: (calzado) =>
                                _navegarARegistrarProduccion(calzado),
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
      ),
    );
  }
}
