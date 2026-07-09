import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inventario/core/theme/app_colors.dart';

import 'package:inventario/clases/mostrar_material.dart';
import 'package:inventario/core/widgets/material_card.dart';
import 'package:inventario/core/widgets/detalle_material_sheet.dart';
import 'package:inventario/formularios/formulario_editar.dart';
import 'package:inventario/formularios/dialogo_eliminar.dart';

class MaterialesView extends StatefulWidget {
  const MaterialesView({super.key});

  @override
  State<MaterialesView> createState() => _MaterialesViewState();
}

class _MaterialesViewState extends State<MaterialesView> {
  final String urlMateriales = 'http://10.0.2.2:3000/api/materiales';
  late Future<List<MaterialModel>> _materialesFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _categoriaSeleccionada = 'Todos';

  final List<String> categoriasFiltro = [
    'Todos',
    'Cuero',
    'Suelas',
    'Hilos',
    'Pegamentos / Tintes',
    'Herrajes / Ojales',
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
      throw Exception('Error del servidor');
    } catch (e) {
      throw Exception('No se pudo conectar: $e');
    }
  }

  // Refrescar
  Future<void> _refrescarLista() async {
    setState(() {
      _materialesFuture = obtenerMateriales();
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

    if (_categoriaSeleccionada != 'Todos') {
      resultado = resultado
          .where((m) => m.categoria == _categoriaSeleccionada)
          .toList();
    }

    return resultado;
  }

  //Mostrar detalle del material
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Inventario de Materiales',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            color: AppColors.primary,
            onPressed: _refrescarLista,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar material',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  "Categoría:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      // ignore: deprecated_member_use
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categoriaSeleccionada,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: categoriasFiltro.map((String cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _categoriaSeleccionada = newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: FutureBuilder<List<MaterialModel>>(
              future: _materialesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final materiales = _filtrarMateriales(snapshot.data ?? []);

                if (materiales.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron materiales'),
                  );
                }

                return ListView.separated(
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
                          'codigo': material.codigo,
                          'insumo': material.insumo,
                          'categoria': material.categoria,
                          'cantidad': material.cantidad,
                          'medida': material.medida,
                          'proveedor': material.proveedor,
                        };

                        final editado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FormularioEditar(material: materialMap),
                          ),
                        );

                        if (editado == true) {
                          _refrescarLista();
                        }
                      },
                      onDelete: () async {
                        final eliminado = await showDialog<bool>(
                          context: context,
                          builder: (_) => DialogoEliminar(
                            codigo: material.codigo,
                            nombre: material.insumo,
                          ),
                        );
                        if (eliminado == true) {
                          _refrescarLista();
                        }
                      },
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
